function get_xml(url::AbstractString; sleep_on_fail=5)
    url = replace(url, " " => "%20")
    r = HTTP.request("GET", url)
    xmldoc = parsexml(String(r.body))
    return root(xmldoc)
end
