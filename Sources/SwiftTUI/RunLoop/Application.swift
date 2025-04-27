//import Foundation
//#if os(macOS)
//import AppKit
//#endif
//
//public actor Application {
// public static let shared = Application()
// private var node: Node!
// private var window: Window!
// private var control: Control!
// private var renderer: Renderer!
//
// typealias InputHandler = (bell: Bool, (InputKey) async -> Bool)
// private static var inputParser: InputParser = .default
// private var arrowKeyParser = ArrowKeyParser()
//
// private static var inputHandlers: [AnyHashable: InputHandler] = [:]
// public static var onInterruption: (() -> Void)?
//
// @Application
// private var invalidatedNodes: [Node] = []
// @Application
// private var updateScheduled = false
//
// public init() {}
//
// @Application
// @inline(__always)
// public init<I: View>(rootView: I) {
//  node = Node(view: VStack(content: rootView).view)
//  node.build()
//
//  control = node.control.unsafelyUnwrapped
//
//  window = Window()
//  window.addControl(control)
//
//  window.firstResponder = control.firstSelectableElement
//  window.firstResponder?.becomeFirstResponder()
//
//  renderer = Renderer(layer: window.layer)
//  window.layer.renderer = renderer
//
//  node.application = self
//  renderer.application = self
// }
//
// @Application
// @discardableResult
// @inline(__always)
// public init<I: View>(_ view: @escaping @autoclosure () -> I) async {
//  self.init(rootView: view())
//  await start()
// }
//
// @Application
// @discardableResult
// @inline(__always)
// public init<I: View>(@ViewBuilder _ view: @escaping () -> I) async {
//  await self.init(view())
// }
//
// @Application
// @discardableResult
// @inline(__always)
// public init<I: View>(runLoopType: RunLoopType, _ view: @escaping @autoclosure () -> I) {
//  self.init(rootView: view())
//  Task {  in start(runLoopType: runLoopType) }
// }
//
// @Application
// @discardableResult
// @inline(__always)
// public init<I: View>(runLoopType: RunLoopType, @ViewBuilder _ view: @escaping () -> I) {
//  self.init(runLoopType: runLoopType, view())
// }
//
// 
// var stdInSource: DispatchSourceRead?
//
// @Application
// @inline(__always)
// private func render() {
//  setInputMode()
//  updateWindowSize()
//  control.layout(size: window.layer.frame.size)
//  renderer.draw()
// }
//
// 
// public func start() async -> Never {
//  Application.shared.assertIsolated()
//  await render()
//
//  let stdInSource = DispatchSource.makeReadSource(fileDescriptor: STDIN_FILENO, queue: .main)
//  stdInSource.setEventHandler(qos: .default, flags: [], handler: handleInput)
//  stdInSource.resume()
//  self.stdInSource = stdInSource
//
//  let sigWinChSource = DispatchSource.makeSignalSource(signal: SIGWINCH, queue: .main)
//  sigWinChSource.setEventHandler(qos: .default, flags: [], handler: handleWindowSizeChange)
//  sigWinChSource.resume()
//
//  signal(SIGINT, SIG_IGN)
//  let sigIntSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
//  sigIntSource.setEventHandler(qos: .default, flags: [], handler: stop)
//  sigIntSource.resume()
//
//  while true {
//   try! await Task.sleep(nanoseconds: .max / 2)
//  }
//  return fatalError()
// }
//
// public enum RunLoopType {
//  /// The default option, using Dispatch for the main run loop.
//  case dispatch
//
//  #if os(macOS)
//  /// This creates and runs an NSApplication with an associated run loop. This allows you
//  /// e.g. to open NSWindows running simultaneously to the terminal app. This requires macOS
//  /// and AppKit.
//  case cocoa
//  #endif
// }
//
// 
// public func start(runLoopType: RunLoopType) -> Never {
//  Application.shared.assertIsolated()
//  Task.detached { @Application in self.render() }
//
//  let stdInSource = DispatchSource.makeReadSource(fileDescriptor: STDIN_FILENO, queue: .main)
//  stdInSource.setEventHandler(qos: .default, flags: [], handler: handleInput)
//  stdInSource.resume()
//  self.stdInSource = stdInSource
//
//  let sigWinChSource = DispatchSource.makeSignalSource(signal: SIGWINCH, queue: .main)
//  sigWinChSource.setEventHandler(qos: .default, flags: [], handler: handleWindowSizeChange)
//  sigWinChSource.resume()
//
//  signal(SIGINT, SIG_IGN)
//  let sigIntSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
//  sigIntSource.setEventHandler(qos: .default, flags: [], handler: stop)
//  sigIntSource.resume()
//
//  switch runLoopType {
//  case .dispatch:
//   return dispatchMain()
//  #if os(macOS)
//  case .cocoa:
//   NSApplication.shared.setActivationPolicy(.accessory)
//   NSApplication.shared.run()
//   return fatalError()
//  #endif
//  }
// }
//
// private nonisolated func setInputMode() {
//  var tattr = termios()
//  tcgetattr(STDIN_FILENO, &tattr)
//  tattr.c_lflag &= ~tcflag_t(ECHO | ICANON)
//  tcsetattr(STDIN_FILENO, TCSAFLUSH, &tattr)
// }
//
// private static var tputBelProcess: Process?
// private static let tputPath = "/usr/bin/tput"
// private static func spawnBell() {
//  guard FileManager.default.fileExists(atPath: tputPath) else { return }
//  let proc = Process()
//  proc.qualityOfService = .userInitiated
//  proc.executableURL = URL(fileURLWithPath: tputPath)
//  proc.arguments = ["bel"]
//  tputBelProcess = proc
// }
//
// private static func ringBell() {
//  if let tputBelProcess {
//   if tputBelProcess.isRunning {
//    tputBelProcess.terminate()
//    spawnBell()
//   }
//   do {
//    try tputBelProcess.run()
//   } catch {
//    self.tputBelProcess = nil
//    ringBell()
//   }
//  } else {
//   spawnBell()
//   ringBell()
//  }
// }
//
// public static func handleInput(
//  bell: Bool = false, with _: InputParser? = nil,
//  _ send: @escaping (InputKey) async -> Bool
// ) {
//  Application.inputHandlers[0] = (bell, send)
// }
//
// private nonisolated func handleInput() {
//  let data = FileHandle.standardInput.availableData
//
//  guard let string = String(data: data, encoding: .utf8) else {
//   return
//  }
//
//  for char in string {
//   if let key = Application.inputParser.parse(character: char) {
//    Task.detached(priority: .userInitiated) {  in
//     for (bell, handler) in Application.inputHandlers.values {
//      let didSend = await handler(key)
//      if bell, !didSend { Application.ringBell() }
//     }
//    }
//
//    if case let .arrowKey(arrow) = key {
//     switch arrow {
//     case .down:
//      Task { @Application in
//       if let next = window.firstResponder?.selectableElement(below: 0) {
//        window.firstResponder?.resignFirstResponder()
//        window.firstResponder = next
//        window.firstResponder?.becomeFirstResponder()
//       }
//      }
//     case .up:
//      Task { @Application in
//       if let next = window.firstResponder?.selectableElement(above: 0) {
//        window.firstResponder?.resignFirstResponder()
//        window.firstResponder = next
//        window.firstResponder?.becomeFirstResponder()
//       }
//      }
//     case .right:
//      Task { @Application in
//       if let next = window.firstResponder?.selectableElement(rightOf: 0) {
//        window.firstResponder?.resignFirstResponder()
//        window.firstResponder = next
//        window.firstResponder?.becomeFirstResponder()
//       }
//      }
//     case .left:
//      Task { @Application in
//       if let next = window.firstResponder?.selectableElement(leftOf: 0) {
//        window.firstResponder?.resignFirstResponder()
//        window.firstResponder = next
//        window.firstResponder?.becomeFirstResponder()
//       }
//      }
//     }
//    } else if char == ASCII.EOT {
//     Task {  in stop() }
//    } else {
//     Task { @Application in
//      window.firstResponder?.handleEvent(char)
//     }
//    }
//   }
//
////   if arrowKeyParser.parse(character: char) {
////    guard let key = arrowKeyParser.arrowKey else { continue }
////    arrowKeyParser.arrowKey = nil
////    if key == .down {
////     if let next = window.firstResponder?.selectableElement(below: 0) {
////      window.firstResponder?.resignFirstResponder()
////      window.firstResponder = next
////      window.firstResponder?.becomeFirstResponder()
////     }
////    } else if key == .up {
////     if let next = window.firstResponder?.selectableElement(above: 0) {
////      window.firstResponder?.resignFirstResponder()
////      window.firstResponder = next
////      window.firstResponder?.becomeFirstResponder()
////     }
////    } else if key == .right {
////     if let next = window.firstResponder?.selectableElement(rightOf: 0) {
////      window.firstResponder?.resignFirstResponder()
////      window.firstResponder = next
////      window.firstResponder?.becomeFirstResponder()
////     }
////    } else if key == .left {
////     if let next = window.firstResponder?.selectableElement(leftOf: 0) {
////      window.firstResponder?.resignFirstResponder()
////      window.firstResponder = next
////      window.firstResponder?.becomeFirstResponder()
////     }
////    }
////   }
//  }
// }
//
// @Application
// func invalidateNode(_ node: Node) {
//  invalidatedNodes.append(node)
//  scheduleUpdate()
// }
//
// @Application
// func scheduleUpdate() {
//  if !updateScheduled {
//   Task {  in
//    await self.update()
//   }
//   updateScheduled = true
//  }
// }
//
// @Application
// private func update() {
//  updateScheduled = false
//
//  for node in invalidatedNodes {
//   node.update(using: node.view)
//  }
//  invalidatedNodes = []
//
//  control.layout(size: window.layer.frame.size)
//  renderer.update()
// }
//
// private nonisolated func handleWindowSizeChange() {
//  Task { @Application in
//   updateWindowSize()
//   control.layer.invalidate()
//   update()
//  }
// }
//
// @Application
// private func updateWindowSize() {
//  var size = winsize()
//  guard ioctl(STDOUT_FILENO, UInt(TIOCGWINSZ), &size) == 0,
//        size.ws_col > 0, size.ws_row > 0
//  else {
//   assertionFailure("Could not get window size")
//   return
//  }
//  window.layer.frame.size = Size(width: Extended(Int(size.ws_col)), height: Extended(Int(size.ws_row)))
//  renderer.setCache()
// }
//
// 
// private func stop() {
//  Task { @Application in renderer.stop() }
//  resetInputMode() // Fix for: https://github.com/rensbreur/SwiftTUI/issues/25
//  Application.onInterruption?()
//  exit(0)
// }
//
// /// Fix for: https://github.com/rensbreur/SwiftTUI/issues/25
// private nonisolated func resetInputMode() {
//  // Reset ECHO and ICANON values:
//  var tattr = termios()
//  tcgetattr(STDIN_FILENO, &tattr)
//  tattr.c_lflag |= tcflag_t(ECHO | ICANON)
//  tcsetattr(STDIN_FILENO, TCSAFLUSH, &tattr)
// }
//}
//
//// import Foundation
//// #if os(macOS)
//// import AppKit
//// #endif
////
//// public class Application {
//// private let node: Node
//// private let window: Window
//// private let control: Control
//// private let renderer: Renderer
////
//// typealias InputHandler = (bell: Bool, (InputKey) async -> Bool)
//// private static var inputParser: InputParser = .default
//// private var arrowKeyParser = ArrowKeyParser()
//// private static var inputHandlers: [AnyHashable: InputHandler] = [:]
//// public static var onInterruption: (() -> Void)?
////
//// private var invalidatedNodes: [Node] = []
//// private var updateScheduled = false
////
//// public init<I: View>(rootView: I) {
////  node = Node(view: VStack(content: rootView).view)
////  node.build()
////
////  control = node.control!
////
////  window = Window()
////  window.addControl(control)
////
////  window.firstResponder = control.firstSelectableElement
////  window.firstResponder?.becomeFirstResponder()
////
////  renderer = Renderer(layer: window.layer)
////  window.layer.renderer = renderer
////
////  node.application = self
////  renderer.application = self
//// }
////
//// var stdInSource: DispatchSourceRead?
////
//// public enum RunLoopType {
////  /// The default option, using Dispatch for the main run loop.
////  case dispatch
////
////  #if os(macOS)
////  /// This creates and runs an NSApplication with an associated run loop. This allows you
////  /// e.g. to open NSWindows running simultaneously to the terminal app. This requires macOS
////  /// and AppKit.
////  case cocoa
////  #endif
//// }
////
//// @inline(__always)
//// private func render() {
////  setInputMode()
////  updateWindowSize()
////  control.layout(size: window.layer.frame.size)
////  renderer.draw()
//// }
////
//// public func start() async {
////  render()
////
////  let stdInSource = DispatchSource.makeReadSource(fileDescriptor: STDIN_FILENO, queue: .main)
////  stdInSource.setEventHandler(qos: .default, flags: [], handler: handleInput)
////  stdInSource.resume()
////  self.stdInSource = stdInSource
////
////  let sigWinChSource = DispatchSource.makeSignalSource(signal: SIGWINCH, queue: .main)
////  sigWinChSource.setEventHandler(qos: .default, flags: [], handler: handleWindowSizeChange)
////  sigWinChSource.resume()
////
////  signal(SIGINT, SIG_IGN)
////  let sigIntSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
////  sigIntSource.setEventHandler(qos: .default, flags: [], handler: stop)
////  sigIntSource.resume()
////
////  while true {
////   try! await Task.sleep(nanoseconds: .max / 2)
////  }
//// }
////
//// public func start(runLoopType: RunLoopType = .dispatch) {
////  render()
////
////  let stdInSource = DispatchSource.makeReadSource(fileDescriptor: STDIN_FILENO, queue: .main)
////  stdInSource.setEventHandler(qos: .default, flags: [], handler: handleInput)
////  stdInSource.resume()
////  self.stdInSource = stdInSource
////
////  let sigWinChSource = DispatchSource.makeSignalSource(signal: SIGWINCH, queue: .main)
////  sigWinChSource.setEventHandler(qos: .default, flags: [], handler: handleWindowSizeChange)
////  sigWinChSource.resume()
////
////  signal(SIGINT, SIG_IGN)
////  let sigIntSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
////  sigIntSource.setEventHandler(qos: .default, flags: [], handler: stop)
////  sigIntSource.resume()
////
////  switch runLoopType {
////  case .dispatch:
////   dispatchMain()
////  #if os(macOS)
////  case .cocoa:
////   NSApplication.shared.setActivationPolicy(.accessory)
////   NSApplication.shared.run()
////  #endif
////  }
//// }
////
//// private func setInputMode() {
////  var tattr = termios()
////  tcgetattr(STDIN_FILENO, &tattr)
////  tattr.c_lflag &= ~tcflag_t(ECHO | ICANON)
////  tcsetattr(STDIN_FILENO, TCSAFLUSH, &tattr)
//// }
////
//// public static func handleInput(
////  bell: Bool = false, with _: InputParser? = nil,
////  _ send: @escaping (InputKey) async -> Bool
//// ) {
////  Application.inputHandlers[0] = (bell, send)
//// }
////
//// private func handleInput() {
////  let data = FileHandle.standardInput.availableData
////
////  guard let string = String(data: data, encoding: .utf8) else {
////   return
////  }
////
////  for char in string {
////   if let key = Application.inputParser.parse(character: char) {
////    // log("handling \(key), handlers: \(Application.inputHandlers.count)")
////    for (bell, handler) in Application.inputHandlers.values {
////     Task {
////      let didSend = await handler(key)
////      if bell, !didSend {
////       let tputPath = "/usr/bin/tput"
////       guard FileManager.default.fileExists(atPath: tputPath) else { return }
////       let proc = Process()
////       proc.executableURL = URL(fileURLWithPath: tputPath)
////       proc.arguments = ["bel"]
////
////       do {
////        try proc.run()
////       } catch {
////        log("\(error)")
////       }
////       proc.waitUntilExit()
////      }
////     }
////    }
////   }
////
//////   if arrowKeyParser.parse(character: char) {
//////    guard let key = arrowKeyParser.arrowKey else { continue }
//////    arrowKeyParser.arrowKey = nil
//////    if key == .down {
//////     if let next = window.firstResponder?.selectableElement(below: 0) {
//////      window.firstResponder?.resignFirstResponder()
//////      window.firstResponder = next
//////      window.firstResponder?.becomeFirstResponder()
//////     }
//////    } else if key == .up {
//////     if let next = window.firstResponder?.selectableElement(above: 0) {
//////      window.firstResponder?.resignFirstResponder()
//////      window.firstResponder = next
//////      window.firstResponder?.becomeFirstResponder()
//////     }
//////    } else if key == .right {
//////     if let next = window.firstResponder?.selectableElement(rightOf: 0) {
//////      window.firstResponder?.resignFirstResponder()
//////      window.firstResponder = next
//////      window.firstResponder?.becomeFirstResponder()
//////     }
//////    } else if key == .left {
//////     if let next = window.firstResponder?.selectableElement(leftOf: 0) {
//////      window.firstResponder?.resignFirstResponder()
//////      window.firstResponder = next
//////      window.firstResponder?.becomeFirstResponder()
//////     }
//////    }
//////   } else if char == ASCII.EOT {
//////    stop()
//////   } else {
//////    window.firstResponder?.handleEvent(char)
//////   }
////  }
//// }
////
//// func invalidateNode(_ node: Node) {
////  invalidatedNodes.append(node)
////  scheduleUpdate()
//// }
////
//// func scheduleUpdate() {
////  if !updateScheduled {
////   DispatchQueue.main.async { self.update() }
////   updateScheduled = true
////  }
//// }
////
//// private func update() {
////  updateScheduled = false
////
////  for node in invalidatedNodes {
////   node.update(using: node.view)
////  }
////  invalidatedNodes = []
////
////  control.layout(size: window.layer.frame.size)
////  renderer.update()
//// }
////
//// private func handleWindowSizeChange() {
////  updateWindowSize()
////  control.layer.invalidate()
////  update()
//// }
////
//// private func updateWindowSize() {
////  var size = winsize()
////  guard ioctl(STDOUT_FILENO, UInt(TIOCGWINSZ), &size) == 0,
////        size.ws_col > 0, size.ws_row > 0
////  else {
////   assertionFailure("Could not get window size")
////   return
////  }
////  window.layer.frame.size = Size(width: Extended(Int(size.ws_col)), height: Extended(Int(size.ws_row)))
////  renderer.setCache()
//// }
////
//// private func stop() {
////  renderer.stop()
////  resetInputMode() // Fix for: https://github.com/rensbreur/SwiftTUI/issues/25
////  Self.onInterruption?()
////  exit(0)
//// }
////
//// /// Fix for: https://github.com/rensbreur/SwiftTUI/issues/25
//// private func resetInputMode() {
////  // Reset ECHO and ICANON values:
////  var tattr = termios()
////  tcgetattr(STDIN_FILENO, &tattr)
////  tattr.c_lflag |= tcflag_t(ECHO | ICANON)
////  tcsetattr(STDIN_FILENO, TCSAFLUSH, &tattr)
//// }
//// }
//
////public protocol App: View {
//// init()
////}
////
////extension App {
//// static func main() async -> Never {
////  await Application.shared.start()
//// }
////
//// 
//// static func main(runLoopType: Application.RunLoopType) -> Never {
////  await Application.shared.start(runLoopType: runLoopType)
//// }
////}
