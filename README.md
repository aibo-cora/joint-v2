<h2>Joint - Customizable Video Streaming Package.</h2> 

This package is meant to give developers control over data in applications with a video over internet component.

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

<b>2. Connecting for a server</b>
<br><br>
After initializing a <code>JointSession</code> object, you are able to connect to the server using:
```swift
  public func connect() { }
```
Observe the <code>status</code> property of the object to make sure the client is connected to the server.

<br><br>

<b>3. Starting session</b>
Once connected, you can start the session:
```swift
  public func start() { }
```
It is important to note that starting a session is possible without first connecting to a server. If this is the case, the framework will begin constructing binary data, but it will not be transported.
<br>Connecting to a server will begin the transport.

<br><br><br>
<code>disconnect(), stop()</code> are available respectively.
  
  
  
  
