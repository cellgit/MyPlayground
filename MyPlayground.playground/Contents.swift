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



// 函数进阶
func printInt(i: Int) {
    print("You Passed\(i)")
}

let funVar = printInt

funVar(2) // 现阶段(swift5)函数调用时不能包含标签,只能在声明时包含标签,即不能将参数标签赋值给一个类型是函数的变量

// 函数作为参数: 理解这个可以写出高阶函数
func useFunction(function: (Int) -> ()) {
    function(3)
}

useFunction(function: printInt)
useFunction(function: funVar)

/* 函数捕获作用域之外的变量
    当函数引用了其作用域之外的变量时,这个变量就被捕获了,它们将会继续存在,而不是在超过作用域后被摧毁
 */





func isEven<T: BinaryInteger>(i: T) -> Bool {
    return i%2 == 0
}

let int8isEven: (Int8) -> Bool = isEven

int8isEven(8)


// 使用 `@objcMembers` 令实例的所有成员在Objective-C中可见
@objcMembers
final class Person: NSObject {
    
    let first: String
    let last: String
    let yearOfBirth: Int
    
    init(first: String, last: String, yearOfBirth: Int) {
        self.first = first
        self.last = last
        self.yearOfBirth = yearOfBirth
        super.init() // 被隐式调用
        
//        let sortByYearAlt: SortDescriptor<Person> = sortDescriptor(key: {$0.yearOfBirth}, by: <)
        
//        sort()
    }
    
    let people = [Person(first: "Emily", last: "Young", yearOfBirth: 2002),
                  Person(first: "David", last: "Gray", yearOfBirth: 1991),
                  Person(first: "Robert", last: "Barnes", yearOfBirth: 1985),
                  Person(first: "Ava", last: "Barnes", yearOfBirth: 2000),
                  Person(first: "Joanne", last: "Miller", yearOfBirth: 1994),
                  Person(first: "Ava", last: "Barnes", yearOfBirth: 1998),]
    
    
    
    typealias SortDescriptor<Root> = (Root, Root) -> Bool
    
    func sortDescriptor<Root, Value>(key: @escaping(Root) -> Value, by areInIncreasingOrder: @escaping(Value, Value) -> Bool) -> SortDescriptor<Root> {
        return {areInIncreasingOrder(key($0), key($1))}
    }
    
    func sort() {
        let sortByYearAlt: SortDescriptor<Person> = sortDescriptor(key: {$0.yearOfBirth}, by: <)
        people.sorted(by: sortByYearAlt)
        
        if let f = people.first {
            print(f)
            
        }
        
    }
}


/* 属性:
 1. 计算属性: 不使用任何内存来存储自己的值. 相反,这个属性每次被访问时,返回值都将被实时计算出来
 */

import CoreLocation

struct GPSTrack {
    // 使用 private(set) 或 fileprivate(set): 将record属性作为外部只读,内部可读可写
    private(set) var record: [(CLLocation, Date)] = []
}

// 创建计算属性
extension GPSTrack {
    var timestamps:[Date] {
        /// 返回GPS追踪的时间戳
        /// 复杂度O(n), n是记录点的数量
        return record.map {$0.1}
    }
}

// 因为没有指定setter, 所以timestamps属性是只读. 它的结果不会被缓存,每次你访问这个属性时,结果都要被计算一遍.

/* 变更观察者(编译时特性): 为属性和变量实现willSet 和 didSet 方法,每次当一个属性被设置时(就算它的值没发生变化), 这两个方法都会被调用
 willSet 和 didSet 本质上是一对属性的简写: 一个是存储值的私有属性;另一个是读取值的公开计算属性,这个计算属性的setter会在将值存储到私有属性之前和/或之后,进行额外的工作
 */

// 可以在子类中重写属性,来添加观察者

class Robot {
    enum State {
        case stopped, movingForward, turingRight, turningLeft
    }
    var state = State.stopped
}

class ObservableRobot: Robot {
    override var state: Robot.State {
        willSet {
            print("Transitioning from \(state) to \(newValue)")
        }
    }
}

var robot = ObservableRobot()
robot.state = .movingForward


/* 延迟存储属性: lazy, 将工作推迟到属性被首次访问
 注: 它是一个返回存储值的闭包表达式. 当属性第一次被访问时,闭包将执行(注意闭包后面的括号), 它的返回值将被存储到属性中
 */

class GPSTrackViewController : UIViewController {
    var track = GPSTrack()
    
    lazy var preview: UIImage = {
        for point in track.record {
            // 进行计算
        }
        return UIImage()
    }()
    
}


// 为Dictionary提供一个下标扩展,进行修改字典
extension Dictionary {
    public subscript<Result>(key: Key, as type: Result.Type) -> Result? {
        get {
            return self[key] as? Result
        }
        set {
            guard let value = newValue else {
                self[key] = nil
                return
            }
            
            guard let value2 = value as? Value else {
                return
            }
            self[key] = value2
        }
    }
}

var japan: [String: Any] = ["name": "Japan",
                            "capital": "Tokyo",
                            "population": 126_740_000,
                            "coordinate": ["latitude": 35.0, "longitude": 139.0]]

japan["coordinate", as: [String: Double].self]?["latitude"] = 36.0

japan["coordinate"]


struct Address {
    var street: String
    var city: String
    var zipCode: String
}

struct Person2 {
    let name: String
    var address: Address
}


let streetKeyPath = \Person2.address.street
let nameKeyPath = \Person2.name



/*
 自动闭包
 */

func and(_ l: Bool, _ r: @autoclosure() -> Bool) -> Bool {
    guard l else {return false}
    return r()
}

and(true, false)
and(false, true)
and(true, true)


// 日志函数
func log(ifFalse condition: Bool, message: @autoclosure () -> (String), file: String = #file, function: String = #function, line: Int = #line) {
    guard !condition else {return}
    print("Assertion failed:\(message()),\(file):\(function)(line\(line)))")
}


// @escaping 逃逸闭包
//func sortDescriptor <Root, Value> (key: @escaping (Root) -> Value,
//                                   by areInIncreasingOrder: @escaping(Value, Value) -> Bool) -> SortDescriptor<Root> {
//    return {areInIncreasingOrder(key($0), key($1))}
//}












