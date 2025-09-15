function edit(tag, timestamp, record)
    if record.log then
        local foundFields = string.find(record.log, "#Fields:")
        if foundFields then
            record["log"] = "#Fields:  x-utc-timestamp  date  time  x-threadid  c-ip  x-authuser  x-authusername  c-func  c-method  cs-uri  time-taken  bytes  x-sourcedevice  x-authmethod  x-authstatus  x-requestid"
        end
        local foundFields = string.find(record.log, "#Remark")
        if foundFields then
            record["log"] = nil
        end
    end
    return 1, timestamp, record
end
