<h2>Joint - Customizable Video Streaming Package.</h2> 

This package is meant to give developers control over data in applications with a video over internet component.

<br><i>Updated for v 0.4</i>

<h5>Examples:</h5>
<ul>
    <li>Live streaming.</li>
    <li>Video chat, including 2+ participants.</li>
</ul>

<h5>Requirements: <code>iOS 13.0</code></h5>

<h3>Usage</h3>

<b>1. Init</b><br>
The package uses several required pieces of information for initialization:<br>
```swift
    let session = JointSession(...)
    ...
    public init(datasource source: String,
                     using method: TransportMethod,
                            video: AVCaptureVideoDataOutput,
                            audio: PassthroughSubject<AVAudioPCMBuffer, Never>) {}
```
<ol>
  <li><code>datasource</code> represents the origin, source, of the data that is being transmitted over the network.</li>
  <li><code>method</code> is an enumeration listing all possible ways of transmitting the data. It has an associated value that has the information about a server that will act as the streaming server.</li>
  <li><code>video</code> is the configured video data output of an <code>AVCaptureSession</code>.</li>
  <li><code>audio</code> is the publisher of <code>AVAudioPCMBuffer</code> chunks coming from a microphone tap.</li>
</ol>

<b>Implementation details</b><br>
```swift
public enum TransportMethod { case MQTT(Server) }
```
MQTT is the first method being added to transport data. There are several MQTT brokers available to choose from. Here is an article listing some with <a href="https://muetsch.io/basic-benchmarks-of-5-different-mqtt-brokers.html">benchmarks.</a>
<br>Some of them offer brokers for development purposes <a href="https://console.hivemq.cloud/">HiveMQ</a>, <a href="https://mosquitto.org/">Mosquitto</a> of charge and AWS images to run production grade servers.
<br>
```swift
public protocol Server: Endpoint, Credentials { }
```
When you setup a type that conforms to the <code>Server</code> protocol, you will be asked to suppy the following:
<ul>
  <li>ip</li>
  <li>port</li>
  <li>username</li>
  <li>password</li>
  <li>secure</li>
</ul>
<code>secure</code> is necessary to identify servers that use <code>TLS</code>.

<br><br>

<b>2. Connecting to a server</b>
<br><br>
After initializing a <code>JointSession</code> object, you are able to connect to the server using:
```swift
    public func connect() { }
```
Observe the <code>status</code> property of the object to make sure the client is connected to the server.

<br><br>

<b>3. Starting session</b>
Starting the capture session to feed the camera preview view:
```swift
    public func startCapture() { }
```
<i>Important</b>Starting a session is possible without first connecting to a server. If this is the case, the framework will begin constructing binary data, but it will not be transported.

<br><br>

<b>4. Broadcast stream channel</b>
Publish a message, containing a unique ID source string, to the general channel to let users know that your live stream has been started. <i>Important</i> Make sure the clients, connecting to the server after a 
stream started, have up to date information about active streams. The clients that had an active stream on the list should be updated when the stream ends.

<br><br>

<b>5. Start transmitting data</b>
```swift
    public func transport(enabled: Bool) { }
```
This toggles the flag to start the flow of data to the server.

<br><br>

<b>6. Receive data</b>
```swift
    /// Update channel list.
    /// - Parameters:
    ///   - subscribeTo: Channels to subscribe to.
    ///   - unsubscribeFrom: Channels to unsubscribe from.
    public func updateLinks(subscribeTo: [String], unsubscribeFrom: [String]) { }
```
To start and stop receiving data, use this function to update the list of channels the client is subscribed to.

<br><br>

<b>7. Ending the session</b>
```swift
    public func stopCapture() { }
```
...
```swift
    public func disconnect() { }
```
  
  
  
  
