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