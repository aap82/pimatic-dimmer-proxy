class DimmerProxyDeviceConfigSchema
  device_id:
    description: "The device id to pass into this device"
    type: "string"
    required: yes
  display_as:
    description: "How the device shall be displayed in mobile-front-end"
    type: "string"
    enum: ['switch', 'dimmer']
    default: 'dimmer'
    required: yes

  @property 'config',
    get: ->
      title: "Dimmer Proxy Device Config"
      type: "object"
      properties:
        device_id: @device_id
        display_as: @display_as
        sync_name:
          description: "Sync this name with name of original device"
          type: "boolean"
          default: no
  constructor: ->
    @device_ids = []

  init: => @device_id.enum = @device_ids
  addDeviceID: (id) => @device_ids.add id
  removeDeviceID: (id) => @device_ids.remove(id)


deviceConfig = new DimmerProxyDeviceConfigSchema()
module.exports = deviceConfig


