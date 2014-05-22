# Changelog

## 0.3.2 - 2014-05-22
* Added optionality to `Watership::Consumer` for greater control over its behavior.

## 0.3.1 - 2014-05-15
* Added `Watership::Consumer` to encapsulate a common pattern.

## 0.3.0 - 2014-03-27
* `Watership.config=` now takes a string representing an AMQP URI, not a path.

## 0.2.6 - 2014-02-26
* Exceptions are now only pushed to Airbrake from the `production` environment.
* You can set Watership's environment with `Watership.environment = [env]`
* You can set Watership's logger with `Watership.logger = [logger]`
