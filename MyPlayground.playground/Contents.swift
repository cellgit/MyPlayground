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



/* 斐波那契数列: 递归和迭代两种方法实现
    除第一个和第二个数字之外,任何数字都是前两个数字之和
 
 例: 0,1,1,2,3,5,8,13,21,34, ...
 
 数列中第n个斐波那契的数值计算公式: fib(n) = fib(n-1) + fib(n-2)
 
 缺陷很明显: n增加1,调用fib(n)会多两次,第四次调用9, 第五次调用15,第十次调用177,第二十次调用21891次
 可以完善: 计算缓存技术
 
 注意: 任何用递归解决的问题也可用迭代解决
 */

// 递归计算

//func fib1 (n: UInt) -> UInt { // 未指定基本情形的无穷递归递归, 会报错: All paths through this function will call itself
//    return fib1(n: n-2) + fib1(n: n-1)
//}


/// 递归计算斐波那契数列
/// - Parameter n: UInt类型, 因为斐波那契数列中没有负数
/// - Returns:
//func fib2 (n: UInt) -> UInt {
//    if n < 2 {// 指定基本情形(base case),否则会发生无穷递归,基本情形用作终止点(stopping point)
//        return n
//    }
//    return fib2(n: n-2) + fib2(n: n-1)
//}


// fib2中会重复计算已经计算的数值,导致调用fib2次数呈指数及增加,下面用缓存技术改善
/// 递归计算斐波那契数列,运用字典缓存计算结果(递归计算中采用倒向计算)
var fibMemo: [UInt: UInt] = [0: 0, 1: 1] // 利用字典将旧的基本案例(old base cases)进行缓存
func fib3 (n: UInt) -> UInt {
    if let result = fibMemo[n] {
        return result
    }
    else {
        fibMemo[n] = fib3(n: n-2) + fib3(n: n-1)
    }
    return fibMemo[n]!
}
fib3(n: 20)


/// 第二种高性能计算斐波那契数列的方法: 迭代法(迭代法中采用正向计算)
func fib4 (n: UInt) -> UInt {
    if n==0 {
        return n
    }
    var last: UInt = 0, next: UInt = 1
    for _ in 1..<n {
        (last, next) = (next, last + next)
    }
    return next
}
fib4(n: 20)









