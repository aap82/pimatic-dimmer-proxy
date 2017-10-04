module.exports = (env) ->
  Promise = env.require('bluebird')
  _ = require './utils'

  class DimmerProxyPlugin extends env.plugins.Plugin
    init:(app, @framework, @config) ->
      @deviceSchema = require('./device-config-schema')
      @framework.deviceManager.registerDeviceClass "DimmerProxy", {
        configDef: @deviceSchema.config,
        createCallback: ((config, lastState) => return new DimmerProxyDevice(@, config, lastState ))
      }
      @framework.on 'after init', @afterInit

    afterInit: =>
      @deviceSchema.init()
      for id, device of @framework.deviceManager.devices when device.hasAction('changeDimlevelTo')
        if device.config.class isnt 'DimmerProxy'
          @deviceSchema.addDeviceID(id)
        else device.init()
      @framework.on 'deviceAdded', (device) =>
        return unless device.hasAction('changeDimlevelTo')
        @deviceSchema.addDeviceID(device.id) if device.config.class isnt 'DimmerProxy'

    getDevice: (id) -> @framework.deviceManager.getDeviceById(id)
    removeDevice: (id) -> @framework.deviceManager.removeDevice(id)

  plugin = new DimmerProxyPlugin()

  class DimmerProxyDevice extends env.devices.DimmerActuator
    constructor: (@plugin, @config) ->
      @id = @config.id
      @name = @config.name
      super()
      @device = null
      if @config.display_as is 'switch'
        @template = 'switch'
        @attributes.dimlevel.hidden = yes
        @attributes.dimlevel.displaySparkline = no
      @init()

    init: =>
      return if @device?
      device = @plugin.getDevice(@config.device_id)
      @setDevice(device) if device?
      return null

    setDevice: (device) =>
      @device = device
      @device.on 'changed', @deviceChanged
      @device.on 'remove', @deviceRemoved
      @device.on "state", @_setState
      @device.on "dimlevel", @_setDimlevel
      if @config.sync_name
        @updateName(@device.name)
        @device.on "nameChanged", @updateName
      @_setDimlevel(device._dimlevel)
      return null
    deviceChanged: (newDevice) =>
      console.log 'device changed'
      @device = null
      @setDevice(newDevice)
    deviceRemoved: =>
      console.log 'device deleted'
      @device = null
      @plugin.removeDevice(@id)
    turnOn: ->
      return Promise.resolve() unless @device?
      return @device.turnOn()
    turnOff: ->
      return Promise.resolve() unless @device?
      return @device.turnOff()
    toggle: ->
      return Promise.resolve() unless @device?
      return @device.toggle()
    changeStateTo: (state) ->
      return Promise.resolve() unless @device?
      return @device.changeStateTo(state)
    changeDimlevelTo: (state) ->
      return Promise.resolve() unless @device?
      return @device.changeDimlevelTo(state)
    getState: -> Promise.resolve(@_state)
    destroy: ->
      if @device?
        @device.removeListener 'changed', @deviceChanged
        @device.removeListener 'remove', @deviceRemoved
        @device.removeListener "state",@_setState
        @device.removeListener "dimlevel", @_setDimlevel
        @device.removeListener "nameChanged", @updateName if @config.sync_name
        @device = null
      super()










  return plugin