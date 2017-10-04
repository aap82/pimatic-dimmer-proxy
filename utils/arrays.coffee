Array::unique ?= ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output

Array::add ?= (val) ->
  idx = @indexOf val
  return @push(val) if idx is -1
  return false
Array::remove ?= (val) ->
  idx = @indexOf val
  return @splice(idx, 1) if idx isnt -1
  return false
Array::clear ?=  ->
  if @.length > 0
    for i in [0...@.length]
      @.pop()
  return
Array::replace ?= (arr2) ->
  @.clear()
  @.push(item) for item in arr2
  return

Array::merge ?= (other) -> Array::push.apply @, other

Array::toDict ?= (key) ->
  dict = {}
  dict[obj[key]] = obj for obj in this when obj[key]?
  dict

Array::where ?= (query) ->
  return [] if typeof query isnt "object"
  hit = Object.keys(query).length
  @filter (item) ->
    match = 0
    for key, val of query
      match += 1 if item[key] is val
    if match is hit then true else false


Array::isEqual ?= (arr2) ->
  length = @.length
  if length != arr2.length
    return false
  i = 0
  while i < length
    if @[i] != arr2[i]
      return false
    i++
  true

Array::changes ?= (oldArr) ->
  added = []
  removed = []
  for item in @
    added.push item if item not in oldArr
  for item in oldArr
    removed.push item if item not in @
  return {
    added
    removed
  }

Array::diff ?= (newArr) ->
  added = []
  removed = []
  for item in newArr
    added.push item if item not in @
  for item in @
    removed.push item if item not in newArr
  changed = (added.length > 0 or removed.length > 0)

  return {
    changed
    added
    removed
  }






