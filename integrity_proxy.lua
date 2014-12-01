local gumbo = require "gumbo"

function add_script(html)
  -- load script
  local f = io.open("/root/integrity_proxy/check.js", "r");
  local script = f:read("*all")
  f.close()

  -- try to insert detector script after head
  local i, j = string.find(html, "<head>")
  if i ~= nil then
    html = string.sub(html, 0, j) .. '\n' .. script .. string.sub(html, j+1)
    return html
  end

  -- try to insert detector script before head
  i, j = string.find(html, "<head")
  if i ~= nil then
    html = string.sub(html, 0, i-1) .. '\n' .. script .. string.sub(html, i)
  else
    print("cannot find head element")
  end

  return html
end

-- add xtag to each element
function add_tag(html)
  local doc = gumbo.parse(html)

  for node in doc:walk() do
    if node.type == "element" then
      node:setAttribute('xtag', '509')
    end
  end

  return doc.documentElement.outerHTML
end

function postorder_add(node)
  local childNodes = node.childNodes
  local length = #childNodes
  if length > 0 then
    for index = 1, length do
      local child = childNodes[index]
      if child.type == "element" then
        postorder_add(child)
      end
    end
  end

  if node.type == "document" then -- we are done
    return
  end

  -- print("set md5 of " .. node.localName)
  -- print(node.innerHTML)
  local md5_8 = string.sub(ngx.md5(node.innerHTML), 0, 8)
  node:setAttribute('ssig', md5_8)
end

function add_hash(html)
  local doc = gumbo.parse(html)

  -- recursively add signature to all element (post-order)
  if doc ~= nil then
    postorder_add(doc)
  end

  return doc.documentElement.outerHTML
end

local res = ngx.location.capture("/proxy" .. ngx.var.uri,
                                 { args = ngx.var.args }) 
if res.status == 200 then
  -- copy original header
  for k, v in pairs(res.header) do
    ngx.header[k] = v
  end

  -- modify content for text/html
  if string.find(ngx.header["Content-Type"], "text/html") then
    res.body = add_script(res.body)
    res.body = add_tag(res.body)
    res.body = add_hash(res.body)
    ngx.header["Content-Length"] = #(res.body)
  end

  ngx.print(res.body)
end
