---
title: 实现 call, apply, bind
date: 2019-10-22 22:04:33
permalink: /pages/44d44e/
titleTag: 专题
categories: 
  - 前端
  - 前端基础
  - 编程语言
  - JavaScript
  - JS 手写题
tags: 
  - 
---
## 背景

要求实现 call, apply, bind。主要目的是熟悉 es5 的规范,以及 es6 上的修改。

本文会以 `mdn 介绍 -> es6 规范 -> 实现 ` 这个顺序来展开 

其中 MDN 介绍用法，一些细节不会提到，在 `规范` 中再详细讲解


## call

### MDN 介绍

[Function.prototype.call()](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Function/call)

`call()` 方法使用一个指定的 `this` 值和单独给出的一个或多个参数来调用一个函数。

```js
function Product(name) {
  this.name = name;
}

function Food(name) {
  // 执行了 this.name = name;
  Product.call(this, name);
}

new Food('cheese').name // cheese
```

### 快速实现

只看上面的介绍，我们先实现一个简单版本。 

然后根据规范，继续优化~

要在指定的 `this` 上调用方法，那我们给该 `this` 增加该方法，并用指定的参数调用它，最后删除该方法。

实现如下：
```js
Function.prototype._call = function (thisArg, ...args) {
  thisArg.fn = this
  var result = thisArg.fn(...args)
  delete thisArg.fn
  return result
}

function Product(name) {
  this.name = name;
}

function Food(name) {
  Product._call(this, name);
}

new Food('cheese').name // cheese
```

先不讨论上述代码有什么问题，看完规范后就知道了。

### 规范

[Function.prototype.call (thisArg , ...args)](https://www.ecma-international.org/ecma-262/6.0/#sec-function.prototype.call)

当以 thisArg 和可选的 arg1, arg2 等等作为参数在 func 上调用 call 方法，采用如下步骤：

1. 如果 [IsCallable](https://www.ecma-international.org/ecma-262/5.1/#sec-9.11)(func) 是 false, 则抛出一个 TypeError 异常。
2. 令 argList 为一个空列表。
3. 如果调用这个方法的参数多于一个，则从 arg1 开始以从左到右的顺序插入至 argList 尾部。
4. 执行 [PrepareForTailCall](https://www.ecma-international.org/ecma-262/6.0/#sec-preparefortailcall)().
5. 返回 [Call](https://www.ecma-international.org/ecma-262/6.0/#sec-call)(func, thisArg, argList).

call 方法的 length 属性是 1。

**NOTE1:** 将 thisArg 值直接传递（不进行修改）给 this 。但是自从 es3 后做了改变，es3、es5及以上的非 strict 模式下会进行如下处理： 当 thisArg 值为 undefined 或 null 时会被替换成全局对象，其他值会被应用 `ToObject` 并将结果作为 this 值。

**NOTE2:** 如果 func 是箭头函数或者绑定函数时，步骤五的 [[Call]] 方法将忽略 thisArg

```js
function test(){
  console.log("this:",this)
}

test.call(null) // this: Window {}
test.call(1) // this: Number {1}
test.call({a:1})// this: {a: 1}
```
```js
'use strict';
function test(){
  console.log("this:",this)
}
test.call(null) // this: null
test.call(1) // this: 1
test.call({a:1})// this: {a: 1}
```
```js
var obj = {
  age:1,
  getAge: function(){
    console.log(this.age,this)
  }
}
var arrow = ()=>{console.log(this.age,this)}
var normal = function(){console.log(this.age,this)}
var bound = obj.getAge.bind(obj)
arrow.call(obj) // undefined Window {}
normal.call(obj) // 1 {age: 1, getAge: ƒ}
bound() // 1
bound.call({}) // 1 {age: 1, getAge: ƒ}
```

### 实现

```js
Function.prototype._call = function (thisArg) {

}
```

① 判断 IsCallable(func)

有 [[Call]] 内部方法的才能返回 true，意味着 func 只能是方法了

```js
var func = this
if(typeof func!=="function"){
  throw TypeError()
}
```

我们在这里进行 `thisArg` 的转换（规范中没提到在哪一步进行，我们直接第一步转了）

```js
// 判断当前是否为 strict 模式
var strict = (function(){ return !this;}())
// 获取全局对象
var globalObject = typeof window !== "undefined"? window: global
// 非 strict 的处理
if(!strict){
  // undefined 或 null 时会被替换成全局对象
  if(typeof thisArg === 'undefined' || thisArg === null){
    thisArg = globalObject
  } else {
    // ToObject
    thisArg = new Object(thisArg);
  }
}
```

② 令 argList 为一个空列表
```js
  var argList = []
```
③ 剩余参数插入 argList

```js
  for (var i = 1; i < arguments.length; i++) {
    argList.push(arguments[i])
  }
```

④ 执行 PrepareForTailCall

内部处理，尾调用优化相关，我们不用管

⑤ 返回 Call(func, thisArg, argList) 执行结果


内部实现为 `func. [[Call]](thisArg,argList)`

我们只能通过给 thisArg 添加 func 方法的方式实现

```js
var sym = Symbol('func')
thisArg[sym] = func
var result = thisArg[sym](...argList)
```

这里用到了 `Symbol` 和 `...` ，当然你可能会说，模拟 es3 的方法怎么用到了 es6 的。

这里只想说，我们进行模拟只是为了更加了解规范，完全的模拟是不可能的，实际运用中也不可能用模拟的。

> 不用 `Symbol` 的话可能就需要生成一个随机的属性名

> 不用 `...` 的话可能就需要用 `eval` 或 `new Function` 解决

最后，给上完整的代码

```js
Function.prototype._call = function (thisArg) {
  var func = this
  if (typeof func !== "function") {
    throw TypeError()
  }
  // 判断当前是否为 strict 模式
  var strict = (function () { return !this; }())
  // 获取全局对象
  var globalObject = typeof window !== "undefined" ? window : global
  // 非 strict 的处理
  if (!strict) {
    // undefined 或 null 时会被替换成全局对象
    if (typeof thisArg === 'undefined' || thisArg === null) {
      thisArg = globalObject
    } else {
      // ToObject
      thisArg = new Object(thisArg);
    }
  }
  var argList = []
  for (var i = 1; i < arguments.length; i++) {
    argList.push(arguments[i])
  }
  var sym = Symbol('func')
  thisArg[sym] = func
  var result = thisArg[sym](...argList)
  delete thisArg[sym]
  return result
}
```

测试用例复用上面的，结果一致。

注意严肃模式要在 _call 定义前声明


### 拓展阅读

1. [JavaScript深入之call和apply的模拟实现](https://juejin.im/post/5907eb99570c3500582ca23c)
2. [面试官问：能否模拟实现JS的call和apply方法](https://juejin.im/post/5bf6c79bf265da6142738b29)

## apply

### MDN 介绍

[Function.prototype.apply()](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Function/apply)

`apply()` 方法调用一个具有给定 `this` 值的函数，以及作为一个数组（或类似数组对象）提供的参数。

```js

Math.max.apply(null, [5, 6, 2, 3, 7]); // 7

```

与之类似的有 [Reflect.apply()](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Reflect/apply) 方法

> Reflect.apply(target, thisArgument, argumentsList)

要调用的方法指定在 target ，相比 `func.apply` ，行为更加统一了


### 快速实现

根据 MDN , 和 call 相比好像就只有参数不一样，有了前面 call 的铺垫，我们得到如下实现

```js
Function.prototype._apply = function (thisArg,argArray) {
  var func = this
  if (typeof func !== "function") {
    throw TypeError()
  }
  // 判断当前是否为 strict 模式
  var strict = (function () { return !this; }())
  // 获取全局对象
  var globalObject = typeof window !== "undefined" ? window : global
  // 非 strict 的处理
  if (!strict) {
    // undefined 或 null 时会被替换成全局对象
    if (typeof thisArg === 'undefined' || thisArg === null) {
      thisArg = globalObject
    } else {
      // ToObject
      thisArg = new Object(thisArg);
    }
  }
  var sym = Symbol('func')
  thisArg[sym] = func
  var result = thisArg[sym](...argArray)
  delete thisArg[sym]
  return result
}

function Product(name) {
  this.name = name;
}

function Food(name) {
  Product._apply(this, [name]);
}

new Food('cheese').name // cheese
```

### 规范

[Function.prototype.apply ( thisArg, argArray )](https://www.ecma-international.org/ecma-262/6.0/#sec-function.prototype.apply)

当以 thisArg 和 argArray 参数在 func 对象上调用 apply 方法时，将执行如下步骤：
1. 如果  IsCallable(func) 为 false，抛出 TypeError 异常
2. 如果 argArray 为 null 或 undefined ，返回 [Call](https://www.ecma-international.org/ecma-262/6.0/#sec-call)(func, thisArg) 的调用结果
3. 令 argList 为 [CreateListFromArrayLike](https://www.ecma-international.org/ecma-262/6.0/#sec-createlistfromarraylike)(argArray).
4. 执行 ReturnIfAbrupt(argList).
5. 执行 PrepareForTailCall
6. 返回 Call(func, thisArg, argList) 调用结果

apply 方法的 length 属性是 2。

**NOTE1** thisArg 传递到 this 的转换，同 call

**NOTE2**  如果 func 是箭头函数或者绑定函数时，步骤 6 的 [[Call]] 方法将忽略 thisArg

### 实现

和 call 一样的步骤就不再重复了

```js
Function.prototype._call = function (thisArg) {
  var func = this
  if (typeof func !== "function") {
    throw TypeError()
  }
  // 判断当前是否为 strict 模式
  var strict = (function () { return !this; }())
  // 获取全局对象
  var globalObject = typeof window !== "undefined" ? window : global
  // 非 strict 的处理
  if (!strict) {
    // undefined 或 null 时会被替换成全局对象
    if (typeof thisArg === 'undefined' || thisArg === null) {
      thisArg = globalObject
    } else {
      // ToObject
      thisArg = new Object(thisArg);
    }
  }
  var sym = Symbol('func')
  thisArg[sym] = func
  // ... 后续处理
}
```

② 如果 argArray 为 null 或 undefined ，返回 `Call(func, thisArg)` 调用结果

```js
  var result;
  if(argArray===null||argArray === void 0){
    result = thisArg[sym]()
  }
```

③ 令 argList 为 [CreateListFromArrayLike](https://www.ecma-international.org/ecma-262/6.0/#sec-createlistfromarraylike)(argArray).

类数组对象转数组

1. Type(argArray) 不是 Object，抛出 TypeError 
2. 获取 argArray 的 length 属性： [ToLength](https://www.ecma-international.org/ecma-262/6.0/#sec-tolength),该阶段可能会抛出 TypeError
3. 令 list 为空 List
4. index 从0开始进行循环，获取 length 次 argArray 的元素，并插入 list。 argArray 元素的获取方法为 argArray[[ToString](https://www.ecma-international.org/ecma-262/6.0/#sec-tostring-applied-to-the-number-type)(index)]
5. 返回 list

```js
  function CreateListFromArrayLike (argArray) {
    if (typeof argArray !== "object") {
      throw TypeError()
    }
    // 按 ToInteger 规范
    function ToInteger (arg) {
      var number = Number(arg)
      if (Number.isNaN(number)) {
        return +0
      } else if (number === 0 || number === Infinity || number === -Infinity) {
        return number
      } else {
        var abs = Math.floor(Math.abs(number))
        return number < 0 ? -abs : abs
      }
    }
    function ToLength (arg) {
      var len = ToInteger(arg)
      if (len <= +0) {
        return +0
      }
      // es6 的定义是 2 ** 53-1, es5 是 2 ** 32 -1
      var max = Math.pow(2, 53) - 1
      if (len === Infinity) {
        return max
      }
      return Math.min(len, max)
    }
    var len = ToLength(argArray.length)
    // array 长度限制
    if(len > 2 ** 32 -1){
      throw RangeError("Invalid array length")
    }
    var list = []
    for (var i = 0; i < len; i++) {
      list[i] = argArray[i]
    }
    return list
  }
```

当然，这其实就是模拟的 es6 的 `Array.from`

④ 生成 argList 时候可能会抛异常

上一步骤中会抛出各种异常

⑥ 返回 Call(func, thisArg, argList) 调用结果

```js
var sym = Symbol('func')
thisArg[sym] = func
var result = thisArg[sym](...argList)
```

最后，给上完整的代码

```js
Function.prototype._apply = function (thisArg, argArray) {
  var func = this
  if (typeof func !== "function") {
    throw TypeError()
  }
  // 判断当前是否为 strict 模式
  var strict = (function () { return !this; }())
  // 获取全局对象
  var globalObject = typeof window !== "undefined" ? window : global
  // 非 strict 的处理
  if (!strict) {
    // undefined 或 null 时会被替换成全局对象
    if (typeof thisArg === 'undefined' || thisArg === null) {
      thisArg = globalObject
    } else {
      // ToObject
      thisArg = new Object(thisArg);
    }
  }
  var sym = Symbol('func')
  thisArg[sym] = func
  var result;
  function CreateListFromArrayLike (argArray) {
    if (typeof argArray !== "object") {
      throw TypeError()
    }
    // 按 ToInteger 规范
    function ToInteger (arg) {
      var number = Number(arg)
      if (Number.isNaN(number)) {
        return +0
      } else if (number === 0 || number === Infinity || number === -Infinity) {
        return number
      } else {
        var abs = Math.floor(Math.abs(number))
        return number < 0 ? -abs : abs
      }
    }
    function ToLength (arg) {
      var len = ToInteger(arg)
      if (len <= +0) {
        return +0
      }
      if (len === Infinity) {
        return Math.pow(2, 53) - 1
      }
      return Math.min(len, Math.pow(2, 53) - 1)
    }
    var len = ToLength(argArray.length)
    var list = []
    for (var i = 0; i < len; i++) {
      list[i] = argArray[i]
    }
    return list
  }
  if (argArray === null || argArray === void 0) {
    result = thisArg[sym]()
  } else {
    var argList = CreateListFromArrayLike(argArray)
    result = thisArg[sym](...argList)
  }
  delete thisArg[sym]
  return result
}
```

简单测试一下

```js
Math.max._apply(null, {0:0,1:1,2:2,length:3}); // 2
```

## bind

### MDN 介绍

[Function.prototype.bind()](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Function/bind)

`bind()` 方法创建一个新的函数，在 `bind()` 被调用时，这个新函数的 `this` 被 `bind` 的第一个参数指定，其余的参数将作为新函数的参数供调用时使用。

```js
var module = {
  x: 42,
  getX: function() {
    return this.x;
  }
}

var unboundGetX = module.getX;
console.log(unboundGetX()); // 全局作用域下调用，输出 undefined

var boundGetX = unboundGetX.bind(module);
console.log(boundGetX()); // 42
```

### 快速实现

bind 需要返回一个函数 bound ，每次执行 bound 的时候都是用最初给定的 this 值去执行被绑定函数。

实现如下：

```js
Function.prototype._bind = function (thisArg, ...args) {
  var callback = this
  return function () {
    return callback.apply(thisArg,args)
  }
}
```
测试效果和上面一致
 

### 规范

[Function.prototype.bind ( thisArg , ...args)](https://www.ecma-international.org/ecma-262/6.0/#sec-function.prototype.bind)

当使用参数 thisArg 和零置多个的 args 调用 bind 方法时，它将执行以下步骤：
1. 令 Target 为 this 值
2. IsCallable(Target) 为 false, 抛出 TypeError 异常
3. 令 args 为一个新的（可能为空）列表，此列表依次包含 thisArg 之后提供的所有参数值
4. 令 F 为 [BoundFunctionCreate](https://www.ecma-international.org/ecma-262/6.0/#sec-boundfunctioncreate)(Target, thisArg, args)
5. ReturnIfAbrupt(F).
6. 令 targetHasLength 为 HasOwnProperty(Target, "length")
7. ReturnIfAbrupt(targetHasLength)
8. 如果 targetHasLength 为 true
   1. 令 targetLen 等于 Get(Target, "length").
   2. ReturnIfAbrupt(targetLen).
   3. 如果 Type(targetLen) 不是 Number，令 L = 0
   4. 否则 令 targetLen =  ToInteger(targetLen)；L = max(0,targetLen - args个数)
9. 否则令 L = 0
10. 令 status = `DefinePropertyOrThrow(F, "length", PropertyDescriptor {[[Value]]: L, [[Writable]]: false, [[Enumerable]]: false, [[Configurable]]: true})`.
11. Assert: status is not an abrupt completion // 内部处理相关
12. 令 targetName 为 Get(Target, "name").
13. ReturnIfAbrupt(targetName).
14. 如果 Type(targetName) 非 String，令 targetName  为 ""
15. 设置函数名：SetFunctionName(F, targetName, "bound"). 
16. 返回 F

bind 方法的 length 属性是 1。

**NOTE1**: 使用 `Function.prototype.bind` 创建的函数对象是奇异（exotic）对象，没有 prototype 属性

**NOTE2**：如果 Target 是箭头函数或者绑定函数，随后的 F 调用不使用传递过来的 thisArg



### 实现

③ 设置 args

```js
var args = [].slice.call(arguments, 1);
```

④ F = [BoundFunctionCreate](https://www.ecma-international.org/ecma-262/6.0/#sec-boundfunctioncreate)(Target, thisArg, args)

创建一个 Bound 方法 F。 规范中此处的描述都是用的内部属性和方法，我们只能结果导向进行实现。

注意以下几个要点：

1. F 执行时的内部方法调用的参数为 args 并上本次执行时带的参数
2. 使用 `Function.prototype.bind` 创建的函数对象是奇异（exotic）对象，没有 prototype 属性
3. 如果 Target 是箭头函数或者绑定函数，随后的 F 调用不使用传递过来的 thisArg
4. new F 的返回值是以 Target 原函数构造器生成的新对象
5. F 原型需要指向 targetFunction 原型以保持原型链
```js
var a = function () { this.name = 1 }
var b = function () { this.age = 1 }
b.prototype = new a()
var bound = b.bind({ name: 2 })
new bound() // {age: 1,__proto__:a{name:1}}`
```

其中第二点没有 es5 的解决方案，要想生成没有 prototype 属性的函数，只能是 bound 函数或 es6+ 新增的特定函数



实现如下：
```js
function BoundFunctionCreate (targetFunction, boundThis, boundArgs) {
  var bound = function () {
    // 1. F 执行时的内部方法调用的参数为 args 并上本次执行时带的参数
    var args = boundArgs.concat([].slice.call(arguments));

    // 4. new F 的返回值是以 Target 原函数构造器生成的新对象
    // 不用 new.target 可以采用 isPrototypeOf 的方法
    if (new.target !== void 0) {
      // 特定函数不能实例化
      if (!targetFunction.hasOwnProperty("prototype")) {
        throw TypeError(`${targetFunction.name || F} is not a constructor`)
      }
      // new 实例化调用时，本处的 this = Object.create(bound.prototype)
      return targetFunction.apply(this,args)
    } else {
      // 普通调用
      // 3. 如果 Target 是箭头函数或者绑定函数，随后的 F 调用不使用传递过来的 thisArg
      // 箭头函数 或 绑定函数不会使用 boundThis 作为 this, 这里第一个参数传什么都无所谓
      // 但简写函数就需要用 boundThis 作为 this
      return targetFunction.apply(boundThis, args)
    }
  }
  // 5. F 原型需要指向 targetFunction 原型以保持原型链
  // 注意这里的实现，bound.prototype 不直接指向 targetFunction.prototype
  // 而是指向一个空对象，该空对象以 targetFunction.prototype 作为原型
  // 这么写是因为绑定函数是没有 prototype 的，所以不会通过 prototype 改到原型的东西，
  // 但我们这里的实现一定会有 prototype，为了不影响到原型，我们采用指向空对象的方式
  if(targetFunction.prototype){
    bound.prototype = Object.create(targetFunction.prototype)
  }
  return bound
}
```

⑥ `var targetHasLength = Target.hasOwnProperty("length")`

⑧、⑨

```js
if(targetHasLength){
  var targetLen = Target.length
  if(typeof targetLen!=="number"){
    var L = 0
  } else {
    var targetLen = ToInteger(targetLen)
    var L = Math.max(0,targetLen - args.length)
  }
} else {
  var L = 0
}
```

⑩ 设置 F 的 length 属性
```js
Object.defineProperty(F, "length", {
  value: L,
  writable: false,
  enumerable: false,
  configurable: true
})
```

12 `var targetName = Target.name`

14 `if(typeof targetName !== "string")targetName = ""`

15 SetFunctionName(F, targetName, "bound"). 

```js
var name = "bound" + " " + targetName
Object.defineProperty(F, "name", {
  value: name,
  writable: false,
  enumerable: false,
  configurable: true
})
```

16 返回 F

完整代码如下：

```js
Function.prototype._bind = function (thisArg) {
  var Target = this
  if (typeof Target !== 'function') {
    throw new TypeError(this + ' must be a function');
  }
  var args = [].slice.call(arguments, 1);
  function BoundFunctionCreate (targetFunction, boundThis, boundArgs) {
    var bound = function () {
      // 1. F 执行时的内部方法调用的参数为 args 并上本次执行时带的参数
      var args = boundArgs.concat([].slice.call(arguments));
  
      // 4. new F 的返回值是以 Target 原函数构造器生成的新对象
      // 不用 new.target 可以采用 isPrototypeOf 的方法
      if (new.target !== void 0) {
        // 特定函数不能实例化
        if (!targetFunction.hasOwnProperty("prototype")) {
          throw TypeError(`${targetFunction.name || F} is not a constructor`)
        }
        // new 实例化调用时，本处的 this = Object.create(bound.prototype)
        return targetFunction.apply(this,args)
      } else {
        // 普通调用
        // 3. 如果 Target 是箭头函数或者绑定函数，随后的 F 调用不使用传递过来的 thisArg
        // 箭头函数 或 绑定函数不会使用 boundThis 作为 this, 这里第一个参数传什么都无所谓
        // 但简写函数就需要用 boundThis 作为 this
        return targetFunction.apply(boundThis, args)
      }
    }
    // 5. F 原型需要指向 targetFunction 原型以保持原型链
    // 注意这里的实现，bound.prototype 不直接指向 targetFunction.prototype
    // 而是指向一个空对象，该空对象以 targetFunction.prototype 作为原型
    // 这么写是因为绑定函数是没有 prototype 的，所以不会通过 prototype 改到原型的东西，
    // 但我们这里的实现一定会有 prototype，为了不影响到原型，我们采用指向空对象的方式
    if(targetFunction.prototype){
      bound.prototype = Object.create(targetFunction.prototype)
    }
    return bound
  }
  var F = BoundFunctionCreate(Target, thisArg, args)
  var targetHasLength = Target.hasOwnProperty("length")
  function ToInteger (arg) {
    var number = Number(arg)
    if (Number.isNaN(number)) {
      return +0
    } else if (number === 0 || number === Infinity || number === -Infinity) {
      return number
    } else {
      var abs = Math.floor(Math.abs(number))
      return number < 0 ? -abs : abs
    }
  }
  if (targetHasLength) {
    var targetLen = Target.length
    if (typeof targetLen !== "number") {
      var L = 0
    } else {
      var targetLen = ToInteger(targetLen)
      var L = Math.max(0, targetLen - args.length)
    }
  } else {
    var L = 0
  }
  Object.defineProperty(F, "length", {
    value: L,
    writable: false,
    enumerable: false,
    configurable: true
  })
  var targetName = Target.name
  if (typeof targetName !== "string") {
    targetName = ""
  }
  var name = "bound" + " " + targetName
  Object.defineProperty(F, "name", {
    value: name,
    writable: false,
    enumerable: false,
    configurable: true
  })
  return F
}
```

测试用例

```js
var A = {
  name: "test",
  arrow: () => this.name,
  shorthand (sex) { return this.name + sex },
  cs: function (sex, age) { return this.name + sex + age }
}

var boundArrow = A.arrow.bind(A)
console.log(boundArrow.name, boundArrow.length, boundArrow()) // bound arrow 0 undefined
var boundArrow2 = A.arrow._bind(A)
console.log(boundArrow2.name, boundArrow2.length, boundArrow2()) // bound arrow 0 undefined

var boundCs = A.cs.bind(A, ",man")
console.log(boundCs.name, boundCs.length, boundCs(",25")) // bound cs 1 test,man,25
var boundCs2 = A.cs._bind(A, ",man")
console.log(boundCs2.name, boundCs2.length, boundCs2(",25")) // bound cs 1 test,man,25


var boundSh = A.shorthand.bind(A, ",man")
console.log(boundSh.name, boundSh.length, boundSh(",25")) // bound shorthand 0 test,man
var boundSh2 = A.shorthand._bind(A, ",man")
console.log(boundSh2.name, boundSh2.length, boundSh2(",25")) // bound shorthand 0 test,man
console.log(boundCs.prototype) // undefined
console.log(boundCs2.prototype) // cs {}

new boundCs // cs {}
new boundCs2 // bound {}

new boundArrow() // Uncaught TypeError: boundArrow is not a constructor
new boundArrow2() // Uncaught TypeError: arrow is not a constructor

new boundSh // Uncaught TypeError: boundSh is not a constructor
new boundSh2 // Uncaught TypeError: shorthand is not a constructor

var a = function () { this.name = 1 }
var b = function () { this.age = 1 }
b.prototype = new a()
var boundB1 = b.bind({ name: 2 })
var boundB2 = b._bind({ name: 2 })
console.log((new boundB1()).name)//1
console.log((new boundB2()).name)//1
```

可以看到，当前实现还有一些问题，目前较难解决。

1. 非构造函数实例化时报错信息中的 func.name 不一样
2. 生成的 bound 函数不应该有 prototype 属性
3. 实例化绑定函数时，返回的结果会多一层 `{__proto__}`

总的来说，完全模拟是不可能的，我们通过分析规范，了解 bind 的内部过程才是王道 ~

### 拓展阅读

1. [面试官问：能否模拟实现JS的bind方法](https://juejin.im/post/5bec4183f265da616b1044d7)