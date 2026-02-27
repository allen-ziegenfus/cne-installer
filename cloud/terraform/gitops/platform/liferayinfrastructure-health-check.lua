hs = {}
if obj.status ~= nil and obj.status.conditions ~= nil then
  for i, condition in ipairs(obj.status.conditions) do
    if (condition.type == "Ready" or condition.type == "Synced") and condition.status == "False" then
      hs.status = "Degraded"
      hs.message = condition.message
      return hs
    end
  end
end
hs.status = "Healthy"
return hs