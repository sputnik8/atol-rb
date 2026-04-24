![ruby-logo](https://www.ruby-lang.org/images/header-ruby-logo.png)
![atol-logo](http://www.atol.ru/site_styles/img/logo-red.png)

[![Gem Version](https://badge.fury.io/rb/atol.svg)](https://badge.fury.io/rb/atol) [![BuildStatus](https://travis-ci.org/sputnik8/atol-rb.png)](https://api.travis-ci.org/sputnik8/atol-rb.png) [![Maintainability](https://api.codeclimate.com/v1/badges/fb0179622d762c8157ba/maintainability)](https://codeclimate.com/github/sputnik8/atol-rb/maintainability) [![Coverage Status](https://coveralls.io/repos/github/sputnik8/atol-rb/badge.svg?branch=master)](https://coveralls.io/github/sputnik8/atol-rb?branch=master)

# atol-rb

Пакет содержит набор классов для работы с [KaaS-сервисом АТОЛ-онлайн](https://online.atol.ru/) по описанному протоколу: [v4](https://atol.online/upload/iblock/dff/4yjidqijkha10vmw9ee1jjqzgr05q8jy/API_atol_online_v4.pdf) и [v5 (ФФД 1.2)](https://atol.online/upload/iblock/c23/q1o62ixkhvgxx413hpo0eaptkf6k5hrk/API%20%D1%81%D0%B5%D1%80%D0%B2%D0%B8%D1%81%D0%B0%20%D0%90%D0%A2%D0%9E%D0%9B%20%D0%9E%D0%BD%D0%BB%D0%B0%D0%B9%D0%BD_v5.pdf).

##### Совместимость

Для корректной работы необходим интерпретатор Руби версии ~> 3.0.0. Пакет работает с версиями протокола [v4](http://atol.online/api_v4) и [v5](http://atol.online/api_v5)  (см. настройку ATOL_API_URL).

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
### Конфигурация в инициализаторе

Для обращения к сервису необходимы данные учетной записи. `login`, `password` и `group_code`

Для Rails-приложений так же можно создать файл инициализации и задать параметры непосредственно в коде:

```ruby
# config/initializers/atol.rb

Rails.application.config.after_initialize do
  Atol.config.tap do |config|
    config.inn                  = '123456789010'
    config.login                = 'example-login'
    config.password             = 'example-password'
    config.payment_address      = 'г. Москва, ул. Ленина, д.1 к.2' # тэг 1187
    config.group_code           = 'example-group-code'
    config.default_sno          = 'esn' # тэг 1055
    config.default_tax          = 'vat18'
    config.callback_url         = 'https://www.example.com/callback_path'
    config.company_email        = 'example@email.com'
    config.default_payment_type = 1 # receipt.payments[].type: 0 — наличные (ФФД тег 1031), 1 — безналичные (ФФД тег 1081)
    config.api_url              = 'https://online.atol.ru/possystem/v5' # по умолчанию 'https://online.atol.ru/possystem/v4' ФФД 1.05
    config.internet             = true # тэг 1125, по умолчанию false
  end
end
```

Для объектов конфигурации используется класс унаследованный от класса из гема [anyway-config](https://github.com/palkan/anyway_config). Другие способы задания конфигурации можно найти в его документации.

### Использование тестового окружения АТОЛ

АТОЛ предоставляет тестовую среду для отработки интеграции. Данные для авторизации в тестовой среде можно найти в [библиотеке документации АТОЛ Онлайн](https://online.atol.ru/lib/), пункт ["Параметры тестовой среды"](https://online.atol.ru/files/ffd/test_sreda.txt)

URL тестовой среды необходимо указывать в конфигурации. При использовании переменных окружения вам необходимо задать переменную `ATOL_API_URL`.

```bash
# .env
ATOL_API_URL=https://testonline.atol.ru/possystem/v5
```

> _Внимание! При создании чеков в тестовой среде АТОЛ будет отправлять письма на электронную почту покупателя._

#### Прокси

Объект конфигурации позволяет задать прокси для http-запросов:

``` ruby
  uri = URI('http://example-proxy.com')
  proxy = Net::HTTP.Proxy(uri.host, uri.port)
  Atol.config.http_client = proxy
```

### Получение токена

Для создания документа в системе АТОЛ необходимо получить токен авторизации. Вот как это можно сделать:

```ruby
token = Atol::Transaction::GetToken.new.call
# => 'example-token-string'
```

Токен можно будет использовать в течение 24 часов после первого запроса.

Сервис АТОЛ не предоставляет информации о сроке жизни токена, поэтому механизм его кеширования полностью зависит от приложения.

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

`agent_info_type` — опциональный аргумент: признак агента по предмету расчёта (тег ФФД 1222).

Массив `items` должен включать в себя объекты, которые так же соответствуют схеме.

#### Items для версии V4

Для создания `items` можно использовать класс `Atol::Request::PostDocument::Item::Body` — он автоматически выбирает реализацию под v4/v5 по `config.api_url` (или `Atol.config.api_url`).

Его конструктор принимает обязательные аргументы `name`, `price`, `payment_method`, `payment_object` и опциональные `quantity` (по умолчанию 1), `supplier_info_inn`, `supplier_info_name`, `agent_info_type` (тег ФФД - 1222).

`supplier_info_inn` обязателен, если передан `agent_info_type`.

Допустимые значения `payment_method`:
```ruby
[
  'full_prepayment', 'prepayment', 'advance', 'full_payment',
  'partial_payment', 'credit', 'credit_payment'
]
```
Допустимые значения `payment_object`:
```ruby
[
  'commodity', 'excise', 'job', 'service', 'gambling_bet', 'gambling_prize',
  'lottery', 'lottery_prize', 'intellectual_activity', 'payment','agent_commission',
  'composite', 'another'
]
```

Например:

```ruby
item = Atol::Request::PostDocument::Item::Body.new(
  name: 'product name',
  price: 100,
  payment_method: 'full_payment',
  payment_object: 'service',
  quantity: 2
).to_h
```

Тогда создание всего тела запроса будет выглядеть так:

```ruby
Atol::Request::PostDocument::Sell::Body.new(
  external_id: 123,
  email: 'example@example.com',
  items: [
    Atol::Request::PostDocument::Item::Body.new(
      name: 'number 9',
      price: 50,
      payment_method: 'full_payment',
      payment_object: 'service',
      quantity: 2
    ).to_h,
    Atol::Request::PostDocument::Item::Body.new(
      name: 'number 9 large',
      price: 100,
      payment_method: 'full_payment',
      payment_object: 'service'
    ).to_h,
    Atol::Request::PostDocument::Item::Body.new(
      name: 'number 6',
      price: 60,
      payment_method: 'full_payment',
      payment_object: 'service'
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

#### Items для версии V5

Создается как в v4 только

- Добавлено обязательное поле `measure`
- Добавлено обязательное поле `vat`
- Изменен тип поля `payment_object` на int

Доступные значения для `measure`

```
0, 10, 11, 12, 20, 21, 22, 30, 31, 32, 40, 41, 42, 50, 51, 70, 71, 72, 73, 80, 81, 82, 83, 255
```

`vat` имеет вид объекта, пример

```
{ type: 'none' }
```
Доступные type для vat
`none vat0 vat5 vat7 vat10 vat22 vat105 vat107 vat110 vat20 vat120 vat122`

Доступные значения для `payment_object`

```
1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23
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

#### Коллбэк регистрации документа

После отправки документа в обработку сервер АТОЛ отправит запрос с состоянием обработки документа на URL, указанный в запросе.

`Atol::Request::PostDocument::Sell::Body` добавить в тело URL, если он будет указан в конфигурации.

На примере Rails-приложения динамический параметр может быть добавлен при инициализации сервера:

```ruby
# config/initializers/atol.rb

Rails.application.config.after_initialize do
  Atol.config.callback_url = Rails.application.routes.url_helpers.atol_callback_url
end

```

#### Запрос статуса документа

Если в течение 300 секунд не поступил запрос с состоянием документа, то необходимо запросить его через get-запрос.

Для этого можно воспользоваться классом `Atol::Transaction::GetDocumentState`, достаточно передать ему токен и uuid документа:

```ruby

response = Atol::Transaction::GetDocumentState.new(token: token, uuid: uuid).call

```
