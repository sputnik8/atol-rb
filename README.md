![ruby-logo](https://www.ruby-lang.org/images/header-ruby-logo.png)
![atol-logo](http://www.atol.ru/site_styles/img/logo-red.png) 

[![Gem Version](https://badge.fury.io/rb/atol.svg)](https://badge.fury.io/rb/atol) [![BuildStatus](https://travis-ci.org/GeorgeGorbanev/atol-rb.png)](https://travis-ci.org/GeorgeGorbanev/atol-rb) [![Maintainability](https://api.codeclimate.com/v1/badges/8c702db502a7a6abdcba/maintainability)](https://codeclimate.com/github/GeorgeGorbanev/atol-rb/maintainability) [![Coverage Status](https://coveralls.io/repos/github/GeorgeGorbanev/atol-rb/badge.svg?branch=master)](https://coveralls.io/github/GeorgeGorbanev/atol-rb?branch=master)

# atol-rb

Пакет содержит набор классов для работы с [KaaS-сервисом АТОЛ-онлайн](https://online.atol.ru/) по [описанному протоколу](https://online.atol.ru/files/%D0%90%D0%A2%D0%9E%D0%9B%20%D0%9E%D0%BD%D0%BB%D0%B0%D0%B8%CC%86%D0%BD._%D0%9E%D0%BF%D0%B8%D1%81%D0%B0%D0%BD%D0%B8%D0%B5%20%D0%BF%D1%80%D0%BE%D1%82%D0%BE%D0%BA%D0%BE%D0%BB%D0%B0.pdf).

##### Совместимость

Для корректной работы необходим интерпретатор Руби версии 2.2 и выше. Пакет работает с версией протокола v3. 


## Использование

### Установка пакета

Необходимо добавить в Gemfile проекта строку:

```ruby
gem 'atol'
```
И запустить команду:

``` 
$ bundle install
```
### Конфигурация

Для обращения к сервису необходимы данные учетной записи.

При инициализации приложение попытается найти необходимые параметры в константе ENV.

Для корректной инициализации потребуются следующие переменные окружения:

```bash
# .env
ATOL_INN=123456789010
ATOL_LOGIN=example-login
ATOL_PASSWORD=example-password
ATOL_PAYMENT_ADDRESS="г. Москва, ул. Ленина, д.1 к.2"
ATOL_GROUP_CODE=example-group-code
```

Для Rails-приложений так же можно создать файл инициализации и задать параметры непосредственно в коде:


```ruby
# config/initializers/atol.rb
 
Rails.application.config.after_initialize do
  Atol.config.tap do |config|
    config.inn             = '123456789010'
    config.login           = 'example-login'
    config.password        = 'example-password'
    config.payment_address = 'г. Москва, ул. Ленина, д.1 к.2'
    config.group_code      = 'example-group-code'
  end
end
```

Для класса конфигурации используется класс из гема [anyway-config](https://github.com/palkan/anyway_config). Другие способы задания конфигурации можно найти в его документации. 

### Получение токена

Для создания документа в системе АТОЛ необходимо получить токен авторизации. Вот как это можно сделать:

```ruby
token = Atol::Transaction::GetToken.new.call
# => 'example-token-string'
```

Токен можно будет использовать в течение 24 часов после первого запроса.

Сервис АТОЛ не предоставляет информации о сроке жизни токена, поэтому его механизм его кеширования полностью зависит от приложения.

### Регистрация документа

#### Создание тела запроса

Тело запроса должно соответствовать схеме. Для упрощения кода создан класс `Atol::Request::PostDocument::Sell::Body`.

Конструктор в качестве обязательных аргументов принимает `external_id`, один из аргументов `phone` или `email` и `items`. 

```ruby
body = Atol::Request::PostDocument::Sell::Body.new(
  external_id: 123,
  email: 'example@example.com',
  items: [
    ...
  ]
).to_json 
```
Массив `items` должен включать в себя объекты, которые так же соответствуют схеме.

Для создания `items` можно использовать класс `Atol::Request::PostDocument::Item::Body`.

Его конструктор принимает обязательные аргументы `name`, `price` и опциональный `quantity` (по умолчанию 1).

```ruby
item = Atol::Request::PostDocument::Item::Body.new(
  name: 'product name',
  price: 100,
  quantity: 2
).to_h
```

Тогда создание всего тела запроса будет выглядеть так:

```ruby
body = Atol::Request::PostDocument::Sell::Body.new(
  external_id: 123,
  email: 'example@example.com',
  items: [
    Atol::Request::PostDocument::Item::Body.new(
      name: 'number 9',
      price: 50,
      quantity: 2
    ).to_h,
    Atol::Request::PostDocument::Item::Body.new(
      name: 'number 9 large',
      price: 100
    ).to_h,
    Atol::Request::PostDocument::Item::Body.new(
      name: 'number 6',
      price: 60
    ).to_h
  ]
).to_json 

```
Результат:
```json

{  
  "receipt":{  
    "attributes":{  
      "sno":"usn_income_outcome",
      "email":"example@example.com"
    },
    "items":[  
      {  
        "name":"number 9",
        "price":50.0,
        "quantity":2.0,
        "sum":100.0,
        "tax":"none"
      },
      {  
        "name":"number 9 large",
        "price":100.0,
        "quantity":1.0,
        "sum":100.0,
        "tax":"none"
      },
      {  
        "name":"number 6",
        "price":60.0,
        "quantity":1.0,
        "sum":60.0,
        "tax":"none"
      }
    ],
    "payments":[  
      {  
        "sum":260.0,
        "type":1
      }
    ],
    "total":260.0
  },
  "service":{  
    "inn":"123456789010",
    "payment_address":"г. Москва, ул. Ленина, д.1 к.2"
  },
  "timestamp":"06.02.2018 12:35:00",
  "external_id":123
}

```
#### Отправка документа

Когда токен и тело запроса составлены, остается только сделать post-запрос.

Для этого используем класс `Atol::Transaction::PostDocument`, принимающий название операции, токен и тело запроса:

```ruby
Atol::Transaction::PostDocument.new(
  operation: :sell,
  token: token,
  body: body
).call
```
Объект возьмет на себя составление URL, добавит необходимые параметры из конфигурации, отправит запрос и вернет объект http-ответа.

В случае возникновения ошибок он вернет исключение специальных классов.

Для логгирования конструктор принимает необязательные аргументы `req_logger` и `res_logger`.

Этими аргументами должны быть объекты, отвечающие на `#call` и принимающие один аргумент, объект запроса или ответа:

```Ruby
Atol::Transaction::PostDocument.new(
  operation: :sell,
  token: token,
  body: body,
  req_logger: lambda { |req| puts req.body },
  res_logger: lambda { |res| puts res.body }
).call
```