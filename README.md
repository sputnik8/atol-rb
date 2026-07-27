![ruby-logo](https://www.ruby-lang.org/images/header-ruby-logo.png)
![atol-logo](http://www.atol.ru/site_styles/img/logo-red.png)

[![Gem Version](https://badge.fury.io/rb/atol.svg)](https://badge.fury.io/rb/atol) [![BuildStatus](https://travis-ci.org/sputnik8/atol-rb.png)](https://api.travis-ci.org/sputnik8/atol-rb.png) [![Maintainability](https://api.codeclimate.com/v1/badges/fb0179622d762c8157ba/maintainability)](https://codeclimate.com/github/sputnik8/atol-rb/maintainability) [![Coverage Status](https://coveralls.io/repos/github/sputnik8/atol-rb/badge.svg?branch=master)](https://coveralls.io/github/sputnik8/atol-rb?branch=master)

# atol-rb

Пакет содержит набор классов для работы с [KaaS-сервисом АТОЛ-онлайн](https://online.atol.ru/) по [описанному протоколу](https://atol.online/upload/iblock/dff/4yjidqijkha10vmw9ee1jjqzgr05q8jy/API_atol_online_v4.pdf).

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
    config.default_payment_type = '1' # тэг 1031
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
ATOL_API_URL=https://testonline.atol.ru/possystem/v4
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

`agent_info_type` опциональный аргумент - признак агента (тег ФФД - 1057)

Массив `items` должен включать в себя объекты, которые так же соответствуют схеме.

#### Items для версии V4

Для создания `items` можно использовать класс `Atol::Request::PostDocument::Item::Body`.

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

#### Кастомные payments

По умолчанию `Sell::Body` формирует один платёж с типом из конфигурации (`default_payment_type`) и суммой, равной итогу позиций. Если нужны другие виды оплаты (например, зачёт аванса — тег 1215, тип `2`), можно передать массив объектов `Atol::Request::PostDocument::Payment` явно. Сумма платежей должна совпадать с итогом позиций, иначе конструктор бросит `Atol::PaymentsTotalMismatchError`.

```ruby
payments = [
  Atol::Request::PostDocument::Payment.new(
    type: Atol::Request::PostDocument::Payment::PREPAID_TYPE,
    sum: 200.0
  )
]
Atol::Request::PostDocument::Sell::Body.new(
  external_id: 123,
  email: 'example@example.com',
  items: [item],
  payments: payments
).to_json
```

Виды оплаты (`type`) — константы класса `Atol::Request::PostDocument::Payment`: `CASH_TYPE` наличные (1031), `CASHLESS_TYPE` безналичный (1081), `PREPAID_TYPE` предоплата/зачёт аванса (1215), `POSTPAID_TYPE` постоплата/кредит (1216), `COUNTER_PROVISION_TYPE` встречное предоставление (1217), `EXTENDED_5_TYPE`–`EXTENDED_9_TYPE` расширенные.

#### Чек коррекции для версии V5

Для тела чека коррекции по ФФД 1.2 (операции `sell_refund_correction`, `sell_correction` и т.п.) используется класс `Atol::Request::PostDocument::Correction::V5::Body`.

Обязательные аргументы: `external_id`, `items`, `correction_type` (`self` или `instruction`) и `base_date` (дата корректируемого расчёта в формате `dd.mm.yyyy`, тег 1178), а также хотя бы один контакт клиента — `phone` или `email`. Необязательные: `base_number` — номер документа-основания (тег 1179, не более 32 байт); `additional_check_props` — дополнительный реквизит чека/БСО (тег 1192, не более 16 байт); и `payments` (как и в `Sell::Body`, при отсутствии формируется один платёж из `default_payment_type` с суммой, равной итогу позиций; переданная сумма платежей должна совпадать с итогом позиций).

```ruby
body = Atol::Request::PostDocument::Correction::V5::Body.new(
  external_id: 123,
  email: 'example@example.com',
  items: [...],
  correction_type: 'self',
  base_date: '01.01.2026',
  base_number: '12345'
).to_json

Atol::Transaction::PostDocument.new(operation: :sell_refund_correction, token: token, body: body).call
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
