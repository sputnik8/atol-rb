![ruby-logo](https://www.ruby-lang.org/images/header-ruby-logo.png)
![atol-logo](http://www.atol.ru/site_styles/img/logo-red.png)

[![Gem Version](https://badge.fury.io/rb/atol.svg)](https://badge.fury.io/rb/atol) [![BuildStatus](https://travis-ci.org/sputnik8/atol-rb.png)](https://api.travis-ci.org/sputnik8/atol-rb.png) [![Maintainability](https://api.codeclimate.com/v1/badges/fb0179622d762c8157ba/maintainability)](https://codeclimate.com/github/sputnik8/atol-rb/maintainability) [![Coverage Status](https://coveralls.io/repos/github/sputnik8/atol-rb/badge.svg?branch=master)](https://coveralls.io/github/sputnik8/atol-rb?branch=master)

# atol-rb

Пакет содержит набор классов для работы с [KaaS-сервисом АТОЛ-онлайн](https://online.atol.ru/) по [описанному протоколу](https://online.atol.ru/files/ffd/API_AO_v4.pdf).

##### Совместимость

Для корректной работы необходим интерпретатор Руби версии 2.5. Пакет работает с версией протокола v4.


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

При инициализации приложение попытается найти необходимые параметры в константе `ENV`.

Для корректной работы потребуются следующие переменные окружения.

**Все переменные являются обязательными**.

```bash
# .env
ATOL_INN=123456789010
ATOL_LOGIN=example-login
ATOL_PASSWORD=example-password
ATOL_PAYMENT_ADDRESS="г. Москва, ул. Ленина, д.1 к.2"
ATOL_GROUP_CODE=example-group-code
ATOL_DEFAULT_SNO=esn
ATOL_DEFAULT_TAX=vat18
ATOL_CALLBACK_URL=https://www.example.com/callback_path
ATOL_COMPANY_EMAIL=example@email.com
ATOL_DEFAULT_PAYMENT_TYPE=1
```

Значения `ATOL_INN`, `ATOL_LOGIN`, `ATOL_PASSWORD`, `ATOL_PAYMENT_ADDRESS` и `ATOL_GROUP_CODE` вы получаете при регистрации в сервисе.

`ATOL_DEFAULT_SNO` - система налогообложения. Возможные значения:
1) "osn" – общая СН;
2) "usn_income" – упрощенная СН (доходы);
3) "usn_income_outcome" – упрощенная СН (доходы минус расходы);
4) "envd" – единый налог на вмененный доход;
5) "esn" – единый сельскохозяйственный налог;
6) "patent" – патентная СН.

`ATOL_DEFAULT_TAX` - номер налога в ККТ. Возможные значения:
1) "none" – без НДС;
2) "vat0" – НДС по ставке 0%;
3) "vat10" – НДС чека по ставке 10%;
4) "vat18" – НДС чека по ставке 18%;
5) "vat110" – НДС чека по расчетной ставке 10/110;
6) "vat118" – НДС чека по расчетной ставке 18/118.

`ATOL_CALLBACK_URL` - адрес, по которому сервис будет отправлять информацию после создания чека.

`ATOL_DEFAULT_PAYMENT_TYPE` - вид оплаты. Возможные значения:
1) "1" – электронный;
2) "2" – "9" – расширенные типы оплаты. Для каждого фискального типа оплаты можно указать расширенный тип оплаты.

`ATOL_COMPANY_EMAIL` - адрес электронной почты вашей компании.

### Конфигурация в инициализаторе

Для Rails-приложений так же можно создать файл инициализации и задать параметры непосредственно в коде:

```ruby
# config/initializers/atol.rb

Rails.application.config.after_initialize do
  Atol.config.tap do |config|
    config.inn                  = '123456789010'
    config.login                = 'example-login'
    config.password             = 'example-password'
    config.payment_address      = 'г. Москва, ул. Ленина, д.1 к.2'
    config.group_code           = 'example-group-code'
    config.default_sno          = 'esn'
    config.default_tax          = 'vat18'
    config.callback_url         = 'https://www.example.com/callback_path'
    config.company_email        = 'example@email.com'
    config.default_payment_type = '1'
  end
end
```

Для объектов конфигурации используется класс унаследованный от класса из гема [anyway-config](https://github.com/palkan/anyway_config). Другие способы задания конфигурации можно найти в его документации.

### Использование тестового окружения АТОЛ

АТОЛ предоставляет тестовую среду для отработки интеграции. Данные для авторизации в тестовой среде можно найти в [библиотеке документации АТОЛ Онлайн](https://online.atol.ru/lib/), пункт ["Параметры тестовой среды"](https://online.atol.ru/files/ffd/test_sreda.txt)

При передаче данных к тестовому API будьте аккуратны, чеки реально отправляются на почту.

Сконфигурировать приложение для работы с тестовой средой можно следующим образом:

```ruby
# config/initializers/atol.rb

Rails.application.config.after_initialize do
  Atol.config.tap do |config|
    config.inn                  = '5544332219'
    config.login                = 'v4-online-atol-ru'
    config.password             = 'iGFFuihss'
    config.payment_address      = 'г. Москва, ул. Ленина, д.1 к.2'
    config.group_code           = 'v4-online-atol-ru_4179'
    config.default_sno          = 'esn'
    # config.default_tax          = 'vat18'
    # config.callback_url         = 'https://www.example.com/callback_path'
    config.company_email        = 'example@email.com'
    # config.default_payment_type = '1'
    config.api_url              = 'https://testonline.atol.ru/possystem/v4/'
  end
end
```

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
Массив `items` должен включать в себя объекты, которые так же соответствуют схеме.

Для создания `items` можно использовать класс `Atol::Request::PostDocument::Item::Body`.

Его конструктор принимает обязательные аргументы `name`, `price`, `payment_method`, `payment_object` и опциональный `quantity` (по умолчанию 1).

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
body = Atol::Request::PostDocument::Sell::Body.new(
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
