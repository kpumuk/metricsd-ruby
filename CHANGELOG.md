## 0.2.4 (August 11, 2011)

Features:

  - Time metrics should be recorded with .time suffix (was _time), status metrics - with .status (was _count)
  - Added Client#record methods (alias of record_value)
  - Removed separator option (it was a temporary solution)

## 0.2.3 (July 27, 2011)

Features:

  - Added ability to specify default group

## 0.2.2 (July 27, 2011)

Bugfixes:

  - Fixed problem in connection establishing code

## 0.2.1 (July 27, 2011)

Bugfixes:

  - Fixed problem with safe_send under Goliath

## 0.2.0 (July 27, 2011)

Features:

  - Added an option to enable or disable client

## 0.1.0 (July 26, 2011)

Features:

  - Complete MetricsD protocol implementation
  - Allows to send multiple metrics in a single network packet
  - Splits metrics to several packets of 250 bytes or less
  - Allows to specify metrics parts separator (temporary solution until all the metrics will be migrated to "." separator)
  - Logs network problems to logger and never throws errors like this.
  - 100% test coverage