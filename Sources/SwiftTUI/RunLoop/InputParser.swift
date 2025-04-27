import Foundation

public enum InputKey: Equatable {
 public enum ArrowKey {
  case up
  case down
  case right
  case left
 }

 case space
 case arrowKey(ArrowKey)
 case `return`
 case key(Character)

 static var up: Self { .arrowKey(.up) }
 static var down: Self { .arrowKey(.down) }
 static var right: Self { .arrowKey(.right) }
 static var left: Self { .arrowKey(.left) }
}

open class InputParser {
 public static let `default` = InputParser()
 public var partial = 0

 open func parse(character: Character) -> InputKey? {
  switch partial {
  case 0:
   switch character {
   case "\u{1b}": partial = 1
    return nil
   case " ": return .space
   case "\n": return .return
   default: return .key(character)
   }
  case 1 where character == "[": partial = 2
   return nil
  case 2:
   switch character {
   case "A": partial = 0
    return .arrowKey(.up)
   case "B": partial = 0
    return .arrowKey(.down)
   case "C": partial = 0
    return .arrowKey(.right)
   case "D": partial = 0
    return .arrowKey(.left)
   default: break
   }
   fallthrough
  default: partial = 0
   return nil
  }
 }
// open func parse(character: Character) -> InputKey? {
//  if partial == 0 {
//   if character == "\u{1b}" {
//    partial = 1
//    return nil
//   }
//   partial = 0
//   if character == " " {
//    return .space
//   }
//   if character == "\n" {
//    return .return
//   }
//   return .key(character)
//  }
//  if partial == 1, character == "[" {
//   partial = 2
//   return nil
//  }
//  if partial == 2 {
//   if character == "A" {
//    partial = 0
//    return .arrowKey(.up)
//   }
//   if character == "B" {
//    partial = 0
//    return .arrowKey(.down)
//   }
//   if character == "C" {
//    partial = 0
//    return .arrowKey(.right)
//   }
//   if character == "D" {
//    partial = 0
//    return .arrowKey(.left)
//   }
//  }
//  partial = 0
//  return nil
// }
}

// import Foundation
//
// public enum InputKey: Equatable {
// public enum ArrowKey {
//     case up
//     case down
//     case right
//     case left
// }
//
// case space
// case arrowKey(ArrowKey)
// case `return`
// case key(Character)
// }
//
// open class InputParser {
// public static let `default` = InputParser()
// public var partial = 0
//
// open func parse(character: Character) -> InputKey? {
//  switch partial {
//  case .zero:
//   switch character {
//   case "\u{1b}": partial = 1
//    return nil
//   case  " " : partial = 0
//    return .space
//   case "\n": partial = 0
//    return .return
//   default: partial = 0
//    return .key(character)
//   }
//  case 1 where character == "[":
//   partial = 2
//   return nil
//  case 2:
//   if partial == 2, character == "A" {
//    partial = 0
//    return .arrowKey(.up)
//   }
//   if partial == 2, character == "B" {
//    partial = 0
//     return .arrowKey(.down)
//   }
//   if partial == 2, character == "C" {
//    partial = 0
//      return .arrowKey(.right)
//   }
//   if partial == 2, character == "D" {
//    partial = 0
//    return .arrowKey(.left)
//   }
//   fallthrough
//  default: partial = 0
//   return nil
//  }
// }
// }
