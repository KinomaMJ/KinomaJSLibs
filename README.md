# KinomaJS BLE V2 API

## Overview
The KinomaJS BLE V2 stack provides an alternate JavaScript API that supports more GATT features compared to the original [V1 BLE API](https://github.com/Kinoma/kinomajs/blob/master/kinoma/kpr/libraries/LowPAN/src/lowpan/ble.js). Notable improvements and features include:

- Modern object-oriented and class-based JavaScript API
- ES6 Promise-based GATT client procedures
- GAP security level settings per characteristic
- User defined characteristic value parser/serializer
- GATT Reliable Write support (TBD)
- GATT Read/Write Long Value support (TBD)

### ES6 module usage
The **lowpan/gatt** module exports the **BLE** class as default, in addition to other common APIs.

```javascript
import BLE, {UUID, BluetoothAddress} from "lowpan/gatt";
```

## GAP API
### BLE Central usage example
```javascript
import BLE from "lowpan/gatt";

/* BLE Instance */
let ble = new BLE();
ble.onReady = () => {
	// BLE Stack is ready to use
	ble.startScanning();
};
ble.onDiscovered = device => {
	// GAP Peripheral is discovered
};
ble.onConnected = connection => {
	// Remote connection has been established
	connection.onDisconnected = () => {
		ble.startScanning();
	};
	// Perform GATT client procedures...
};
```

### BLE Peripheral usage example
```javascript
import BLE from "lowpan/gatt";

/* BLE Instance */
let ble = new BLE();

let advertisingParameters = {
	scanResponse: {
		incompleteUUID16List: ["180D"]
		completeName: "Polar H7 252D9F"
	}
};

ble.onReady = () => {
	// BLE Stack is ready to use
	ble.startAdvertising(advertisingParameters);
};
ble.onConnected = connection => {
	// Remote connection has been established
	ble.stopAdvertising();
	connection.onDisconnected = () => {
		ble.startAdvertising(advertisingParameters);
	};
};
```

### BLE class
#### Constructor
**BLE([clearBondings])**  
The optional *clearBondings* argument is a boolean. The GAP bonding database will be cleared when ``clearBondings`` is set ``true``.  

#### Properties
**configuration** *Read Only*  
Shorthand object for configuring BLL. Refer to the **init(bllName)** example below for details.

**server** *Read Only*  
A GATT server instance of the BLE stack's **Profile** class. Refer to the **GATT API** section for further detail.  

#### Callback events
**onConnected(connection)**  
The callback is called when the BLE stack successfully connects to a BLE central or peripheral. The **connection** is an instance of **BLEConnection**.  

**onDiscovered(device)**  
The callback is called when a BLE peripheral is discovered. The **device** parameter describes the peripheral device discovered and  includes following properties:

 * The **connectable** property is a boolean that specifies whether remote device is connectable.
 * The **address** property is an instance of **BluetoothAddress** that represents the remote address.
 * The **rssi** property is a number that represents the RSSI (current signal strength). Units are dBm, in range -127 to +20.
 * The **advertising** property includes the properties for advertisement. See **GAP Advertisement Data Structure** section for detail.
 * The **scanResponse** property includes the properties for scan response. See **GAP Advertisement Data Structure** section for detail.

**onPrivacyEnabled(address)**   
The callback is called when GAP a privacy feature has been enabled.  The **address** is an instance of **BluetoothAddress** that represents the current private resolvable address.  

**onReady()**  
The callback is called when the BLE stack is ready to use.  


#### Common methods
**connect([address, parameters])**  
Initiate an asynchronous connection to a BLE peripheral. Typically this method will be called by BLE Central role. The optional **address** argument is an instance of **BluetoothAddress** or ``null``. If **address** is provided and not ``null``, the BLE stack performs the *Direct Connection Establishment* procedure, otherwise the BLE stack will perform the *Auto Connection Establishment Procedure* using the white list previously provided.  
The optional **parameters** object must include the following properties:

 * The **intervalMin** property specifies the minimum connection event interval.
   * Range: 0x0006 to 0x0C80
   * Time: N * 1.25 msec
 * The **intervalMax** property specifies the maximum connection event interval.
   * Range: 0x0006 to 0x0C80
   * Time: N * 1.25 msec
 * The **timeout** property specifies the supervision timeout for the LE link.
   * Range: 0x000A to 0x0C80
   * Time: N * 10 msec
 * The **latency** property specifies the Slave latency.
   * Range: 0x0000 to 0x01F3

The **onConnected** callback is called when a connection is established with a BLE Peripheral.  

**disablePrivacy()**  
Disables the GAP privacy feature.  

**enablePrivacy()**  
Enables the GAP privacy feature. Refer to the *Core 4.2 Specification, Vol 3, Part C: Generic Access Profile, 10.7 Privacy Feature* for details.  

**init(bllName)**  
Call once immediately after the BLL is configured to initialize the BLE stack. The **onReady** callback is called after BLE stack sucessfully initializes.  

```javascript
/* BLL Configuration */
Pins.configure({
	ble: ble.configuration
}, success => {
	if (!success) {
		throw new Error("Unable to configure BLE");
	}
	/* Initialize BLE Stack w/ BLL Name */
	ble.init("ble");
});
```

**isReady()**  
Returns **true** when the BLE stack is ready to use.  

**startAdvertising(parameters)**  
Start asynchronous GAP advertising. Typically this method will be called by BLE Peripheral or BLE Broadcaster role. The optional **parameters** argument may include following properties:

 * The optional **discoverable** property is a boolean and will be used to determine the current Discoverable mode. This property is set ``true`` by default.
   * When **discoverable** property is ``true``: The optional **limited** property is a boolean and specifies Discoverable mode is either *Limited Discoverable Mode* or *General Discoverable Mode*, otherwise *General Discoverable Mode* by default.
   * When **discoverable** property is ``false``: Discoverable mode will be *Non-Discoverable Mode*
 * The optional **connectable** boolean property is used to determine the current Connectable mode. This property is set ``true`` by default.
   * When **connectable** property is ``true``: The optional **address** property is an instance of **BluetoothAddress** and specifies that Connectable mode is *Directed Connectable Mode*, otherwise *Undirected Connectable Mode*.
   * When **connectable** property is ``false``: Connectable mode will be *Non-Connectable Mode*
 * The optional **advertising** property may include additional properties for advertisement. See **GAP Advertisement Data Structure** section for details.
 * The optional **scanResponse** property may includes the properties for scan response. See the **GAP Advertisement Data Structure** section for details.

The **onConnected** callback is called when this peripheral connects with a central.  
Refer to *Core 4.2 Specification, Vol 3, Part C: Generic Access Profile 9* for further details for discoverable modes and connectable modes.  

```javascript
/* Limited Discoverable Mode & Undirected Connectable Mode */
ble.startAdvertising({
	discoverable: true,
	limited: true,
	connectable: true,
	scanResponse: {
		completeName: "Kinoma Create"
	}
});
```
```javascript
/* Broadcast Mode: i.e. Non-Discoverable Mode & Non-Connectable Mode */
ble.startAdvertising({
	discoverable: false,
	connectable: false,
	advertising: {
		shortName: "Kinoma"
	}
});
```

**startScanning([parameters])**  
Start asynchronous GAP scanning.  Typically this method will be called by BLE Central or BLE Observer role. The optional **parameters** argument may include following properties:

 * The mandatory **observer** property is a boolean and specifies whether stack will act as an Observer; i.e. will discover all advertising packets.
   * When **observer** property is ``true``: The mandatory **active** property is a boolean and specifies whether stack will peform active scanning.
   * When **observer** property is ``false``: The optional **limited** property is a boolean and specifies whether stack will perform the *Limited Discovery Procedure*; i.e. will only discover peripherals when the Flags AD type is present and the *LE Limited Discoverable Flag* is set to one. Otherwise the stack performs the *General Discovery Procedure* by default.
 * The mandatory **duplicatesFilter** property is a boolean and specifies whether stack will enable filtering of duplicate advertising data.
 * The optional **interval** & **window** properties specify the scan interval and the scan window.
   * Range: 0x0004 to 0x4000
   * Time: N * 0.625 msec

The **onDiscovered** callback will be called for each device discovered.  
If no parameters are provided, stack will perform the *General Discovery Procedure* by default and enable duplicates filtering.  

The following example shows how to configure the BLE stack as Oan bserver i.e. to perform *Observation Procedure*. When **observer** property is ``true``, the stack reports all advertising packets via the **onDiscovered** callback.

```javascript
/* Observation Procedure: Receive all advertising packets, passive scanning, filter off */
ble.startScanning({
	observer: true,				// Observer role
	active: false,				// Passive scanning
	duplicatesFilter: false		// No duplicates filtering
});
```

**stopAdvertising()**  
Stop asynchronous GAP advertising.  

**stopScanning()**  
Stop asynchronous GAP scanning.  

### BLEConnection class
#### Properties
**address** *Read Only*  
An instance of the **BluetoothAddress** class corresponding to the address of the remote device.  

**client** *Read Only*  
A GATT client instance of the **Profile** class dedicted to this connection. Refer to the **GATT API** section for further details.  

**parameters** *Read Only*  
Current connection parameters used by the LE link, which includes the following properties:

 * The **interval** property specifies the connection event interval.
   * Range: 0x0006 to 0x0C80
   * Time: N * 1.25 msec
 * The **timeout** property specifies the supervision timeout for the LE link.
   * Range: 0x000A to 0x0C80
   * Time: N * 10 msec
 * The **latency** property specifies the Slave latency.
   * Range: 0x0000 to 0x01F3

#### Callback events
**onAuthenticationCompleted(bonded)**  
The callback is called when the BLE Security Manager completes a pairing and/or bonding procedure on the connection. The boolean **bonded** parameter specifies whether or not the remote device was previously bonded.  

**onAuthenticationFailed(reasonCode, pairing)**    
The callback is called when the BLE Security Manager fails to complete a pairing and/or bonding procedure on the connection. The boolean **pairing** argument is set ``true`` when the procedure fails due to a pairing error. Refer to *Core 4.2 Specification, Vol 2, Part D: Error Codes* for the list of **reasonCode** values.  

**onDisconnected(reasonCode)**   
The callback is called when the connection is disconnected. Refer to *Core 4.2 Specification, Vol 2, Part D: Error Codes* for the list of **reasonCode** values.  

**onPasskeyRequested(input)**   
The callback is called when the BLE Security Manager requires the client to provide a passkey code. The passkey code is provided by calling the **passkeyEntry** method. The boolean **input** parameter is set ``true`` if the local device is an input device, i.e. user may be requested to input the passkey code. If the parameter is set ``false`` then the local device is considered an output device. In this case, the device may generate and display the passkey code.  

**onUpdated()**  
The callback is called when the connection parameter is updated.  

#### Methods
**disconnect([reasonCode])**  
Terminate the connection. The optional **reasonCode** specifies the reason code. Refer to *Core 4.2 Specification, Vol 2, Part D: Error Codes* for the list of **reasonCode** values. The **onDisconnected** callback is called when the disconnection completes.  

**isPeripheral()**  
Returns `true` when the remote device is a BLE peripheral.  

**passkeyEntry(passkey)**  
Provides a temporary passkey used by the Security Manager during a pairing procedure. The **passkey** argument must be a numeric string between "000000" and "999999".  

**readRSSI()**  
Read remote device RSSI. This method returns a **Promise** object.  
 
```javascript
connection.readRSSI().then(rssi => {
	// Read RSSI value
});
```

**setSecurityParameter(parameter)**  
Set the security parameter corresponding to how the Security Manager performs pairing/bonding with the remote device. The **parameter** object may include the following properties:

 * The **bonding** property is a boolean that specifies whether or not the GAP layer enables *Bondable mode*.
 * The **mitm** property is a boolean that specifies whether or not the SM layer uses authenticated MITM protection.
 * The **display** and **keyboard** properties are boolean that specify the IO capabilities of the device.

```javascript
connection.setSecurityParameter({
	bonding: true,		// Enable Bonding
	mitm: false,		// Disable MITM
	display: false,		// Display (for Passkey) is NOT available
	keyboard: false		// Keyboard (for Passkey) is NOT available
});
```

**startAuthentication()**  
Start authentication on the connection.  

**updateConnection(parameters[, l2cap])**  
Start an asynchronous connection update procedure. The mandatory **parameters** object must include the following properties:

 * The **intervalMin** property specifies the minimum connection event interval.
   * Range: 0x0006 to 0x0C80
   * Time: N * 1.25 msec
 * The **intervalMax** property specifies the maximum connection event interval.
   * Range: 0x0006 to 0x0C80
   * Time: N * 1.25 msec
 * The **timeout** property specifies the supervision timeout for the LE link.
   * Range: 0x000A to 0x0C80
   * Time: N * 10 msec
 * The **latency** property specifies the Slave latency.
   * Range: 0x0000 to 0x01F3

The optional **l2cap** property is a boolean that explicitly configures the GAP layer to use the *L2CAP Connection Parameter Update Request*.

```javascript
connection.updateConnection({
	intervalMin: 0x18,
	intervalMax: 028,
	timeout: 3200,
	latency: 0,
});
```

### GAP Advertisement Properties
Refer to the *CSS v6, Part A: Data Types Specifications* for a description of the data types.

**incompleteUUID16List**  
An array of strings corresponding to *Incomplete List of 16-bit Service UUIDs*.  
**completeUUID16List**  
An array of strings corresponding to *Complete List of 16-bit Service UUIDs*.  
**incompleteUUID128List**  
An array of strings corresponding to *Incomplete List of 128-bit Service UUIDs*.  
**completeUUID128List**  
An array of strings corresponding to *Complete List of 128-bit Service UUIDs*.  
**shortName**  
A string corresponding to the *Shortened Local Name*.  
**completeName**  
A string corresponding to the *Complete Local Name*.  
**flags**  
A number corresponding to the *Flags*.  
**manufacturerSpecific**  
An object corresponding to the *Manufacturer Specific Data* with the following properties:

 * The **identifier** property is a number corresponding to the *Company Identifier Code*.
 * The **data** property is an array of numbers corresponding to additional manufacturer specific data.

**txPowerLevel**  
A number corresponding to the *TX Power Level*.  
**connectionInterval**  
An object corresponding to the *Slave Connection Interval Range* with the following properties:

 * The **intervalMin** property is a number corresponding to the minimum connection interval value.
 * The **intervalMax** property is a number corresponding to the maximum connection interval value.

**solicitationUUID16List**  
An array of strings corresponding to the *List of 16 bit Service Solicitation UUIDs*.  
**solicitationUUID128List**  
An array of strings corresponding to the *List of 128 bit Service Solicitation UUIDs*.  
**serviceDataUUID16**  
An object corresponding to the *Service Data - 16 bit UUID* with the following properties:

 * The **uuid** property is a string corresponding to the 16-bit Service UUID.
 * The **data** property is an array of numbers corresponding to additional service data.

**serviceDataUUID128**  
An object corresponding to *Service Data - 128 bit UUID* with the following properties:

 * The **uuid** property is a string corresponding to the 128-bit Service UUID.
 * The **data** property is an array of numbers corresponding to additional service data.

**appearance**  
A number corresponding to the *Appearance*.  
**publicAddress**  
A string corresponding to the *Public Target Address*.  
**randomAddress**  
A string corresponding to the *Random Target Address*.  
**advertisingInterval**  
A number corresponding to the *Advertising Interval*.  
**role**  
A number corresponding to the *LE Role*.  
**uri**  
A string represents *Uniform Resource Identifier*.  

## GATT API
### GATT Server example
This example shows how to setup a "GAP Service" in your application. The API object model is based on the GATT profile hierarchy specification. To simplify the code, we only add the "Device Name" characteristic here.  

```javascript
/* Add GAP service */
let gapService = ble.server.addService({
	uuid: "1800",
	primary: true
});
/* Add "Device Name" characteristic */
gapService.addCharacteristic({
	uuid: "2A00",				// Device Name UUID
	properties: 0x02,		// Read-Only
	formats: ["utf8s"],		// Format is UTF8S
	value: "Kinoma"			// Initial value
});
/* Deploy service */
ble.server.deploy();
```

### GATT Client example
This example shows how to subscribe to a GATT characteristic notification using multiple GATT procedures.  

```javascript
let client = connection.client;
let service;
/* Perform primary service discovery */
client.discoverAllPrimaryServices().then(() => {
	/* Upon completion the service instance will be cached */
	service = client.getServiceByUUID(UUID.getByUUID16(0x180D));
	if (service == null) {
		throw "Heart rate service not found";
	}
	/* Perform characteristic discovery */
	return service.discoverAllCharacteristics();
}).then(() => {
	/* Check if the desired characteristic is found */
	let characteristic = service.getCharacteristicByUUID(UUID.getByUUID16(0x2A37));
	if (characteristic == null) {
		throw "Measurement characteristic not found";
	}
	/* Setup the callback*/
	characteristic.onNotification = value => {
		// Value is notified...
	};
	/* Perform characteristic descriptor discovery */
	return characteristic.discoverAllCharacteristicDescriptors();
}).then(() => {
	/* Check if client configuration is available */
	let descriptor = characteristic.getDescriptorByUUID(UUID.getByUUID16(0x2902));
	if (descriptor == null) {
		throw "Client configuration is not available";
	}
	/* Write value "Notification" */
	return descriptor.writeDescriptorValue(0x0001);
}).then(() => {
	// Configured
});
```

### Profile class
#### Common properties
**services**  
An ``Array`` of all service objects, created by the user when in the BLE server role, or discovered when in the BLE client role.   

#### Common methods
**getServiceByUUID(uuid)**  
Returns a **service** object corresponding to the provided **uuid** object, or ``null`` if no service matching the **uuid** is found.  

#### Server methods
**addService(template)**  
Adds a new service from the **template** configuration object. This method returns a **service** object. The **template** object includes the following properties:

 * The **uuid** property is mandatory and corresponds to either a UUID object or a string representation of this service's UUID.
 * The **primary** property is optional. When provided, this boolean parameter is set `true` when the service is a primary service and set `false` when the service is a secondary service.  

```javascript
let service = server.addService({
	uuid: "180D",
	primary: true
});
```

**deploy()**  
Start hosting GATT services. After services are successfully deployed to the local ATT database, the service object(s) are added to the **services** property, and can be retrieved by calling the **getServiceByUUID** method.  

#### Client methods
**discoverAllPrimaryServices()**  
**discoverPrimaryServiceByServiceUUID(uuid)**  
Perform a *Primary Service Discovery* procedure. Discovered primary service object(s) are added to the **services** property, and can be retrieved by calling the **getServiceByUUID** method. This method returns a **Promise** object.  

```javascript
/* Perform primary service discovery */
client.discoverAllPrimaryServices().then(() => {
	/* Upon completion the service instance will be cached */
	let service = client.getServiceByUUID(uuid);
	// Do more procedures with service...
});
```

**exchangeMTU(mtu)**  
Perform the MTU exchange a.k.a. *Server Configuration* procedure. This method returns a **Promise** object.  

```javascript
/* Perform server configuration */
client.exchangeMTU(158).then(() => {
	// Configured
});
```

<!--BF 09/09/16: Still need a description of the readMultipleCharacteristicValues function below-->
<!--SU 09/13/16: TODO-->
**readMultipleCharacteristicValues(characteristics, sizeList)**  
Call to perform a *Read Multiple Characteristic Values* procedure.

### Service class
#### Common properties
**characteristics** *Read Only*  
``Array`` of all characteristic objects created (for server role) or discovered (for client role).  

**end** *Read Only*  
The ending handle value of this service. For server role, the value is 0 if the service has not yet been deployed.  

**includes** *Read Only*  
``Array`` of all (included) service objects, included by the user (for server role) or discovered (for client role).   

**start** *Read Only*  
The starting handle value of this service. For server role, the value is 0 if the service has not yet been deployed.  

**uuid** *Read Only*  
UUID object corresponding to the UUID of this service.  

#### Common methods
**getCharacteristicByUUID(uuid)**  
Returns the characteristic object matching the provided **uuid** object, or ``null`` if the characteristic is not found.  

**getIncludedServiceByUUID(uuid)**  
Returns an included **service** object matching the provided **uuid** object, or ``null`` if the included service is not found.  

#### Server methods
**addCharacteristic(template)**  
Adds a new characteristic from the **template** configuration object. This method returns a **charactertistic** object. The **template** object includes the following properties:

 * **uuid** is mandatory and corresponds to either a **UUID** object or string representation of this characteristic's UUID.
 * **properties** is a mandatory bit-masked flag value that maps to the GATT *Charactertistic Properties*. Each flag corresponds to a behavior of this characteristic.  
 * **extProperties** is an optional number parameter that corresponds to the GATT *Characteristic Extended Properties*. To enable extended properties, **properties** must include the *Extended Properties (0x80)* flag. The *Writable Auxiliaries (0x0002)* flags of **extProperties** is used to determine whether to provide *Characteristic User Description* descriptor.  
 * The **description**, **value**, **formats**, **security**, **clientConfigurationSecurity**, and **descriptionSecurity** properties can additionally be included in the **template** property.

```javascript
let characteristic = service.addCharacteristic({
	uuid: "e233a9b1-8e54-46ed-b716-8e06092caf10",
	/* Enable Read & Write, but no Write Without Response and Signed Writes */
	properties: 0x02 | 0x08
});
```
```javascript
let characteristic = service.addCharacteristic({
	uuid: "e233a9b1-8e54-46ed-b716-8e06092caf10",
	/* Read only, but also notifiable so the Client Characteristic Configuration Descriptor will be available. */
	properties: 0x02 | 0x10
});
```

**addIncludedService(service)**  
Adds a **service** object to the GATT include definition of this service.  

#### Client methods
**discoverAllCharacteristics()**  
**discoverCharacteristicsByUUID(uuid)**  
Call to perform a *Characteristic Discovery* procedure. Discovered characteristic object(s) are added to the **characteristics** property, and can be retrieved by calling the **getCharacteristicByUUID** or **getCharacteristicByHandle** methods. This method returns **Promise** object.  

**findIncludedServices()**  
Call to perform a *Relationship Discovery* procedure. Discovered included service object(s) are added to the **includes** property, and can be retrieved by calling the **getIncludedServiceByUUID** method. This method returns a **Promise** object.  

**getCharacteristicByHandle(handle)**  
Returns a **characteristic** object matching the provided handle, or ``null`` if the characteristic is not found.  

**readUsingCharacteristicUUID(uuid)**  
Call to perform a *Read Using Characteristic UUID* sub-procedure of the *Characteristic Value Read* procedure. Any newly available characteristics are added to the **characteristics** property. This method returns a **Promise** object.  

### Characteristic class
#### Common properties
**descriptors** *Read Only*  
Array of all **descriptor** objects, created by the user (for server role) or discovered (for client role).  

**formats** *Write Only*  
Array of format names for this characteristic value, corresponding to  the *Characteristic Presentation Format* descriptor(s).  
Specifying multiple formats will make a *Characteristic Aggregate Format* descriptor available, and the value will be treated as an array. Refer to *Core 4.2 Specification, Vol 3, Part G: Generic Attribute Profile, Table 3.16 Characteristic Format types* for a description of format names (Short Name).  
Note that a **serializer** or **parser** will take precedence when available.  

```javascript
characteristic.formats = ["utf8"];		// Format specifying a single UTF8 string value.
characteristic.value = "Hello World";
```
```javascript
characteristic.formats = ["uint8", "boolean"];	// Format specifying an array consisting of an uint8 and a boolean.
characteristic.value = [0xA0, true];
```

**handle** *Read Only*  
Number that represents the handle of this characteristic. On server role, 0 if not deployed yet.  

**parser(packet)** *Write Only*   
Parses a raw ATT value packet into a JavaScript object.  

```javascript
/* Parse a two octet little-endian packet into a UInt16 value */
characteristic.parser = packet => {
	let value = 0;
	value |= packet[0] & 0xFF;
	value |= (packet[1] << 8) & 0xFF;
	return value;
};
```

**properties** *Read Only*  
Number corresponding to the GATT *Characteristic Properties*. Refer to *Core 4.2 Specification, Vol 3, Part G: Generic Attribute Profile, Table 3.5 Characteristic Properties bit field*.  

**serializer(value)** *Write Only*  
Packetizes a value object.  

```javascript
/* Serializer that packetizes a UInt16 value into two octets stored in little-endian order. */
characteristic.serializer = value => {
	let packet = new Array(2);
	packet[0] = value & 0xFF;
	packet[1] = (value >> 8) & 0xFF;
	return packet;
};
characteristic.value = 0x180D;
```

**uuid** *Read Only*  
**UUID** object corresponding to the UUID of this characteristic.  

**value**  
Object corresponding to the value of this characteristic.  
Before the value is sent to the remote device, the object will be serialized to an ``Array`` of bytes if a **serializer** or the format is available, otherwise the object will be treated as an array of bytes and will be sent without serialization. After the value is received from the remote device, the array of bytes is parsed into the corresponding object and stored into this property if a **parser** or the format is available, otherwise the raw array of bytes is stored into this property.

For a server role, the value will be provided to the remote device immediately. Note that setting the **value** does not trigger and indication or notification. The user must first call **notifyValue** and/or **indicateValue**.  

#### Server properties
<!--BF 09/09/16: The server properties all appear to map to specific definitions in the Core spec. Either you need to put a note at the top of this section with a reference to the corresponding Core spec section or detail each property with a reference back to the spec.-->
<!--SU 09/13/16: TODO-->
**clientConfigurationSecurity** *Write Only*  
GAP security setting corresponding to this characteristic client configuration. (*Client Characteristic Configuration* descriptor)  

**description**  
String corresponding to the GATT *Characteristic User Description*.  

**descriptionSecurity** *Write Only*  
GAP security setting corresponding to this characteristic user description. (*Characteristic User Description* descriptor)  

**extProperties** *Read Only*  
Number corresponding to GATT *Characteristic Extended Properties*.  

**security** *Write Only*  
Object that specifies the read/write GAP security setting for this characteristic value.  

```javascript
characteristic.security = {
	read: null,	// No Encryption nor Authentication (LE security mode 1 - Level 1)
	write: {
		/* LE security mode 1 - Level 3 */
		encryption: true,			// Require Encryption
		authentication: true,		// Require Authenticated-Encryption
		secureConnection: false		// Require No LE Secure Connection
	}
};
```

#### Server callback events
**onValueRead()**  
This callback is called when this characteristic's value is read by a remote device. In the callback, set the characteristic **value** property to have the value sent back to the remote device.

```javascript
characteristic.onValueRead = () => {
	/* Value 'foo' will be sent to the remote device */
	characteristic.value = foo;
};
```

**onValueWrite()**   
This callback is called when this characteristic's value has been written by remote device.  

```javascript
characteristic.onValueWrite = () => {
	/* Set 'foo' to the value written by the remote device */
	foo = characteristic.value;
};
```

#### Client properties
**end** *Read Only*  
Ending handle numeric value of this characteristic if known, otherwise **end** will be the same handle value as the **handle** property.  

#### Client callback events
**onIndication**   
This callback is called when the value has been indicated by the remote device, before confirmation is sent.  

**onNotification**   
This callback is called when the value has been notified by the remote device.  

#### Common methods
**getDescriptorByUUID(uuid)**  
Returns a **descriptor** object matching the provided uuid object, or ``null`` if the descriptor is not found. If there are multiple descriptors with the same UUID, only first matching **descriptor** is returned.  

#### Server methods
**notifyValue(bearer[, value])**  
Performs a *Charactertistic Value Notfication* procedure. The optional **value** parameter will be set before the procedure is performed.  

```javascript
characteristic.value = newValue;
/* Perform characteristic value notification */
characteristic.notifyValue(bearer);
```

**indicateValue(bearer[, value])**  
Performs a *Charactertistic Value Indication* procedure. The optional **value** parameter will be set before the procedure is performed. This method returns a **Promise** object.  

```javascript
/* Perform characteristic value indication */
characteristic.indicateValue(bearer, newValue).then(() => {
	/* Confirmation has been received */
});
```

#### Client methods
**discoverAllCharacteristicDescriptors()**  
Performs a *Characteristic Descriptor Discovery* procedure. Discovered descriptor object(s) are added to the **descriptors** property, and can be retrieved by calling the **getDescriptorByUUID** method. This method returns a **Promise** object.  

**readCharacteristicValue([length])**  
Performs a *Read Characteristic Value* and/or *Read Long Characteristic Values* sub-procedure of *Characteristic Value Read* procedure. The optional **length** is only used when performing the *Read Long Characteristic Values* sub-procedure. This method returns a **Promise** object.  

**writeWithoutResponse(signed[, value])**  
Performs a **Write Without Response** sub-procedure of *Characteristic Value Write* procedure. The optional **value** will be set before the procedure is performed.  

**writeCharacteristicValue([value])**  
Performs a *Write Characteristic Value* sub-procedure of *Characteristic Value Write* procedure. The optional **value** will be set before the procedure is performed. This method returns a **Promise** object.  

### Descriptor class
#### Common properties
**uuid** *Read Only*  
UUID object corresponding to the UUID of this **descriptor**.  

**value**  
Object corresponding to the value of this **descriptor**.  

#### Server properties
**readable** *Write Only*  
Setting this property to ``true`` makes this descriptor readable by the remote device.  

<!--BF 09/09/16: Need more information here or a reference to the Core spec-->
<!--SU 09/13/16: TODO-->
**security** *Write Only*  
GAP security setting for this descriptor value.  

**writable** *Write Only*  
Setting this property to ``true`` makes this descriptor writable by the remote device.  

#### Server callback events
**onValueRead**   
This callback is called when this descriptor value has been attemped to be read by remote device.  

**onValueWrite**   
This callback is called when this descriptor value has been written by remote device.  

#### Client properties
**handle** *Read Only*  
Number corresponding to the handle of this descriptor.  

#### Client methods
**readDescriptorValue([length])**  
Performs a *Read Characteristic Descriptors* and/or *Read Long Characteristic Descriptors* sub-procedure of the *Characteristic Descriptors* procedure. The optional **length** is only used only when performing the *Read Long Characteristic Descriptors* sub-procedure. This method returns a **Promise** object.  

**writeDescriptorValue([value])**  
Performs a *Write Characteristic Descriptors* sub-procedure of the *Characteristic Descriptors* procedure. The optional **value** is set before the procedure is performed. This method returns a **Promise** object.  

## Common API
### UUID Object
```javascript
let uuid1 = UUID.getByUUID([0x00, 0x18]);								// Instantiate a UUID object representing the 16-bit UUID '0x1800'.
let uuid2 = UUID.getByString("72C90001-57A9-4D40-B746-534E22EC9F9E");	// Instantiate a UUID object representing a 128-bit UUID.
let uuid3 = UUID.getByUUID16(0x1800);									// Instantiate a UUID object representing the 16-bit UUID '0x1800'.
uuid1.equals(uuid3);	// Returns 'true'
```
#### Static methods
**getByUUID(byteArray)**  
Returns a UUID object corresponding to the **byteArray**.  

**getByString(uuidString)**  
Returns a UUID object corresponding to the **uuidString** string representation.  

**getByUUID16(uuid16)**  
Returns a UUID object corresponding to the 16-bit **uuid16** number.  

#### Common methods
**equals(target)**  
Return `true` if this UUID equals the **target** UUID.  

**getRawArray()**  
Returns the internal byte array.  

**isUUID16()**  
Returns `true` if this UUID is a 16-bit UUID.  

**toString()**  
Returns a string representation of this UUID.  

**toUUID16()**  
Returns a number corresponding to the 16-bit UUID.  

**toUUID128()**  
Returns an array corresponding to the 128-bit UUID.  

### BluetoothAddress
```javascript
// Instantiate a BluetoothAddress object representing a static random address
let address = BluetoothAddress.getByAddress([0xD4, 0x42, 0xFF, 0x4C, 0x6A, 0xFC], true);

address.isRandom();		// Returns 'true'
address.isIdentity();	// Returns 'true'
address.isResolvable();	// Returns 'false'
address.toString();		// Returns "FC:6A:4C:FF:42:D4"
let address2 = BluetoothAddress.getByString("FC:6A:4C:FF:42:D4", true);
address.equals(address2);	// Returns 'true'
```
#### Static methods
**getByAddress(byteArray, random)**  
Returns a new BluetoothAddress object corresponding to the **byteArray**. The **random** argument will be set to ``true`` if the address is a random address otherwise ``false``.  

**getByString(addressString, random)**  
Returns a new BluetoothAddress object corresponding to the **addressString** string. The **random** argument is set to ``true`` if the address is a random address otherwise ``false``.  

#### Common properties
**type** *Read Only*  
Number corresponding to the BLE address type. (i.e. The two most significant bits of the address.).  

**typeString** *Read Only*  
String representation of this BLE address type.  

#### Common methods
**equals(target)**  
Returns `true` if this BLE address equals the *target* address.  

**getRawArray()**  
Returns the internal byte array.  

**isIdentity()**  
Return ``true`` if this BLE address is a public address or static random address.  

**isRandom()**  
Return ``true`` if this BLE address is a random address.  

**isResolvable()**  
Returns **true** if this BLE address is a resolvable private address.  

**toString()**  
Returns the string representation of this BLE address.  <table width="100%" border="1" cellspacing="4">

##Metadata
<x-app-info>
	<table width="100%" border="0" cellspacing="4">
		<tbody>
			<tr>
				<th width="20%" align="right">Module ID</th>
				<td colspan="4">
					<id>kinoma/kpr/libraries/LowPAN/</id>
				</td>
			</tr>
			<tr>
				<th width="20%" align="right">Description</th>
				<td colspan="4">
					<description>Bluetooth 4.0 Low Energy stack</description>
				</td>
			</tr>
			<whitelisted>
				<tr>
					<th align="right">Whitelisted</th>
					<td width="20%">Platform(s):</td>
					<td width="20%">
						<platforms>*</platforms>
					</td>
					<td width="20%">Variant(s):</td>
					<td width="20%">
						<variants>*</variants>
					</td>
				</tr>
			</whitelisted>
			<blacklisted>
				<tr>
					<th align="right">Blacklisted</th>
					<td>Platform(s):</td>
					<td>
						<platforms/>
					</td>
					<td>Variant(s):</td>
					<td>
						<variants>linux/bg3cd</variants>
					</td>
				</tr>
			</blacklisted>
			<footprints>
				<tr>
					<th align="right">Storage Footprint (bytes)</th>
					<th colspan="2">Platform</th>
					<th colspan="2">Binary Size</th>
				</tr>
				<footprint>
					<tr>
						<th align="right"/>
						<td colspan="2">
							<platform>mac</platform>
						</td>
						<td colspan="2">
							<fileSize>123123123</fileSize>
						</td>
					</tr>
				</footprint>
				<footprint>
					<tr>
						<th align="right"/>
						<td colspan="2">
							<platform>win</platform>
						</td>
						<td colspan="2">
							<fileSize>678678678</fileSize>
						</td>
					</tr>
				</footprint>
			</footprints>
			<dependencies>
				<tr>
					<th align="right">Dependencies</th>
					<th colspan="2" align="center">ID</th>
					<th align="center">Platform(s)</th>
					<th align="center">Variant(s)</th>
				</tr>
				<dependency>
					<tr>
						<th align="right"/>
						<td colspan="2">kinoma/kpr/extensions/fakextension/</td>
						<td align="center">
							<platforms>linux/aspen,linux/gtk</platforms>
						</td>
						<td align="center">
							<variants>*</variants>
						</td>
					</tr>
				</dependency>
			</dependencies>
			<urls>
				<tr>
					<th align="right">Related URLs</th>
					<th colspan="2" align="center">URL</th>
					<th colspan="2" align="center">Type</th>
				</tr>
				<url>
					<tr>
						<th align="right"/>
						<td colspan="2">
							<url>http://kinoma.com/develop/documentation/tutorials/ble-miselu-keyboard/</url>
						</td>
						<td colspan="2" align="center">
							<type>Tutorial</type>
						</td>
					</tr>
				</url>
				<url>
					<tr>
						<th align="right"/>
						<td colspan="2">
							<url>http://kinoma.com/develop/documentation/tutorials/ble-griffin-pm/</url>
						</td>
						<td colspan="2" align="center">
							<type>Tutorial</type>
						</td>
					</tr>
				</url>
				<url>
					<tr>
						<th align="right"/>
						<td colspan="2">
							<url>http://kinoma.com/develop/documentation/tutorials/ble-satechi-iq-plug/</url>
						</td>
						<td colspan="2" align="center">
							<type>Tutorial</type>
						</td>
					</tr>
				</url>
			</urls>
		</tbody>
	</table>
	</x-app-info>
