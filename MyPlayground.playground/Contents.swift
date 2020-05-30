import UIKit

var str = "Hello, playground"



// 柯里化: 量产相似方法

func addTo(_ adder: Int) -> (Int) -> Int {
    return { num in
        return num + adder
    }
}
let addTwo = addTo(2)
let result = addTwo(6)


func greaterThan(_ compare: Int) -> (Int) -> Bool {
    return { $0 > compare }
}
let greaterThan10 = greaterThan(10)
greaterThan10(13)
greaterThan10(9)


// 关于Selector

protocol TargetAction {
    func performAction()
}

struct TargetActionWrapper<T: AnyObject>: TargetAction {
    
    weak var target: T?
    
    let action: (T) -> () -> ()
    
    func performAction() -> () {
        if let t = target {
            action(t)()
        }
    }
}

enum ControlEvent {
    case TouchUpInside
    case ValueChanged
    // ...
}

class Control {
    var actions = [ControlEvent: TargetAction]()
    
    func setTarget<T: AnyObject>(target: T, action: @escaping(T) -> () -> (), controlEvent: ControlEvent) {
        actions[controlEvent] = TargetActionWrapper(target: target, action: action)
    }
    
    func removeTargetForControlEvent(contrlEvent: ControlEvent) {
        actions[contrlEvent] = nil
    }
    
    func performActionForControlEvent(controlEvent: ControlEvent) {
        actions[controlEvent]?.performAction()
    }
}




// 将protocol方法声明为mutating
/* 注释:
    - mutating关键字修饰为了能在该方法中修改struct或是enum的变量; class中本来就可以随意修改变量,所以可以不需要`mutating`
 */

protocol Vehicle {
    var numberOfWheels: Int {get}
    var color: UIColor {get set}
    
    mutating func changeColor()
}

struct MyCar: Vehicle {
    let numberOfWheels: Int = 4
    var color = UIColor.blue
    
    mutating func changeColor() {
        color = .red
    }
}

// Sequence

class ReverseIterrator<T>: IteratorProtocol {
    
    
    typealias Element = T
    
    var array: [Element]
    
    var currentIndex = 0
    
    init(array: [Element]) {
        self.array = array
        
        currentIndex = array.count - 1
    }
    
    func next() -> T? {
        if currentIndex < 0 {
            return nil
        }
        else {
            let element = array[currentIndex]
            currentIndex -= 1
            return element
        }
    }
}




