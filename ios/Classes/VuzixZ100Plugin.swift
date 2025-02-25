import Flutter
import UltraliteSDK
import UIKit
import CoreBluetooth

public class VuzixZ100Plugin: NSObject, FlutterPlugin {
    private var manager: UltraliteManager?
    private var connectionStateEventSink: FlutterEventSink?
    private var deviceEventsEventSink: FlutterEventSink?
    private var displayTimeout: Int = 60
    private var textHandle: Int?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "vuzix_z100_plugin", binaryMessenger: registrar.messenger())
        let instance = VuzixZ100Plugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        // Set up event channels for connection state and device events
        let connectionStateChannel = FlutterEventChannel(name: "vuzix_z100_plugin/connection_state", binaryMessenger: registrar.messenger())
        connectionStateChannel.setStreamHandler(instance)
        
        let deviceEventsChannel = FlutterEventChannel(name: "vuzix_z100_plugin/device_events", binaryMessenger: registrar.messenger())
        deviceEventsChannel.setStreamHandler(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            
        case "initialize":
            manager = UltraliteManager.shared
            if let device = manager?.currentDevice {
                if device.isConnected.value == true {
                    connectionStateEventSink?("connected")
                }
            }
            result(true)
            
        case "connect":
            // Show the pairing picker to let user select a device
            let pickerController = UltralitePickerController()
            pickerController.title = "Select Vuzix Device"
            if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                rootViewController.present(pickerController, animated: true) {
                    // After picker is dismissed, check if we have a device
                    if let _ = self.manager?.currentDevice {
                        self.connectionStateEventSink?("connected")
                        result(true)
                    } else {
                        result(FlutterError(code: "NO_DEVICE", message: "No device selected", details: nil))
                    }
                }
            } else {
                result(FlutterError(code: "NO_ROOT_VIEW", message: "Could not show device picker", details: nil))
            }
            
        case "disconnect":
            if let device = manager?.currentDevice {
                device.releaseControl()
                connectionStateEventSink?("disconnected")
            }
            result(true)
            
        case "getDeviceInfo":
            if let device = manager?.currentDevice, let peripheral = device.peripheral {
                let info: [String: Any] = [
                    "name": peripheral.name ?? "",
                    "id": peripheral.identifier.uuidString,
                    "isConnected": device.isConnected.value
                ]
                result(info)
            } else {
                result(FlutterError(code: "NO_DEVICE", message: "No device connected", details: nil))
            }
            
        case "sendText":
            guard let args = call.arguments as? [String: Any],
                  let text = args["text"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Text argument is required", details: nil))
                return
            }
            
            if let device = manager?.currentDevice {
                // Request control with canvas layout
                if device.requestControl(layout: .canvas, timeout: displayTimeout, hideStatusBar: true) {
                    // Remove previous text if it exists
                    if let textHandle = textHandle {
                        _ = device.canvas.removeText(id: textHandle)
                    }
                    
                    // Create new text in the center of the display
                    self.textHandle = device.canvas.createText(text: text, textAlignment: .center, textColor: .white, anchor: .center, xOffset: 0, yOffset: 0)
                    device.canvas.commit()
                    result(true)
                } else {
                    result(FlutterError(code: "CONTROL_ERROR", message: "Failed to get control of device", details: nil))
                }
            } else {
                result(FlutterError(code: "NO_DEVICE", message: "No device connected", details: nil))
            }
            
        case "clearDisplay":
            if let device = manager?.currentDevice {
                if let textHandle = textHandle {
                    _ = device.canvas.removeText(id: textHandle)
                    device.canvas.commit()
                }
                device.releaseControl()
                self.textHandle = nil
                result(true)
            } else {
                result(FlutterError(code: "NO_DEVICE", message: "No device connected", details: nil))
            }
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

extension VuzixZ100Plugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        if let args = arguments as? [String: Any],
           let channel = args["channel"] as? String {
            switch channel {
            case "connection_state":
                connectionStateEventSink = events
            case "device_events":
                deviceEventsEventSink = events
            default:
                break
            }
        }
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        if let args = arguments as? [String: Any],
           let channel = args["channel"] as? String {
            switch channel {
            case "connection_state":
                connectionStateEventSink = nil
            case "device_events":
                deviceEventsEventSink = nil
            default:
                break
            }
        }
        return nil
    }
}
