:local targets "ispa:1.1.1.1 ispb:8.8.8.8 ispc:8.8.4.4"
:local node "customerx"
:local testCount 3
:local apiUrl "https://www.nusa.net.id/push/multi-isp"
:local apiKey "0123456789abcdef"

:local separatorPos -1
:local target ""
:local isp ""
:local dst ""
:local testResult 0
:local postData ""
:local status "0"
:local mimeHeader "Content-Type: application/json"
:local authHeader "X-Api-Key: $apiKey"
:local httpHeaders "$mimeHeader,$authHeader"

:while ($targets != "") do={
    :set separatorPos [:find $targets " "]

    :if ($separatorPos > -1) do={
        :set target [:pick $targets 0 $separatorPos]
        :set targets [:pick $targets ($separatorPos + 1) [ :len $targets]]
    } else={
        :set target $targets
        :set targets ""
    }

    :set separatorPos [:find $target ":"]
    :if ($separatorPos > -1) do={
        :set isp [:pick $target 0 $separatorPos]
        :set dst [:pick $target ($separatorPos + 1) [:len $target]]
        :set testResult [/ping $dst count=$testCount]
        :if ($testResult < $testCount) do={
            :set status "0"
        } else={
            :set status "1"
        }
        :set postData ("{\"node\":\"$node\",\"isp\":\"$isp\",\"status\":$status}")
        :do {
            /tool fetch \
                http-header-field=$httpHeaders \
                http-method=post http-data=$postData url=$apiUrl
        } on-error={
            :log warning "Failed to send data for $isp to $apiUrl"
        }
    }
}
