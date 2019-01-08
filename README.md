# DynamicDigital
UILabel dynamic digital extention base on GCD and Method-Swizzling,
support float and Integer Conversion

UILabel 基于 GCD 和方法交换的动态数字扩展,支持浮点数和整数互转，需要自取

# Usage
```
// Set your animation duration and everything is done. "dynamicDigitalAnimation = 0" represents no animation.
yourUILabel.dynamicDigitalAnimation = 1; 

// Set your origin digital number.
yourUILabel.text = @"0";
// Set your target digital number,it cause an animation automatically.
yourUILabel.text = @"25"
```

### float to float
![img](https://github.com/hon-key/DynamicDigital/blob/master/float-float..gif)

### int to int
![img](https://github.com/hon-key/DynamicDigital/blob/master/int-int.gif)
