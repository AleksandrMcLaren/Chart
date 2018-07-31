
import Foundation
import PlaygroundSupport

var str = "Hello!"

func genRandom(min: Double, max: Double) -> Double {
    return Double(arc4random()) / 0xFFFFFFFF * (max - min) + min
}

func roundToDecimal(_ value: Double, scale: Int) -> Decimal {
    var valueDecimal = Decimal(value)
    var roundedValue = Decimal()
    NSDecimalRound(&roundedValue, &valueDecimal, scale, NSDecimalNumber.RoundingMode.plain)
    return roundedValue
}

let scale = 3
let countValues = 500
let minValue: Double = 0.5
let maxValue: Double = 10

let randomValues = (1...countValues).map{_ in genRandom(min: minValue, max: maxValue)}
let sumValues = randomValues.reduce(0, +)
let percentValue = sumValues / 100
var times = [Any]()
var sumPercents = [Any]()

/// Алгоритм 1 ----------------------------------------

var percents = [Decimal]()

var startTime = CFAbsoluteTimeGetCurrent()
for value in randomValues {
    let percent = value / percentValue
    let roundedPercent = roundToDecimal(percent, scale: scale)
    percents.append(roundedPercent)
}
times.append(CFAbsoluteTimeGetCurrent() - startTime)
sumPercents.append(percents.reduce(0, +))

/// Алгоритм 2 ----------------------------------------

let formatter = NumberFormatter()
formatter.numberStyle = .decimal
formatter.maximumFractionDigits = scale
formatter.minimumFractionDigits = scale
formatter.roundingMode = .halfUp

var stringPercents = [String]()

startTime = CFAbsoluteTimeGetCurrent()
for value in randomValues {
    let percent = value / percentValue
    if let roundedPercent = formatter.string(from: NSNumber(value: percent)) {
        stringPercents.append(roundedPercent)
    }
}
times.append(CFAbsoluteTimeGetCurrent() - startTime)
sumPercents.append("strings")

/// Алгоритм 3 ----------------------------------------

var doublePercents = [Double]()
let divisor = pow(10.0, Double(scale))

startTime = CFAbsoluteTimeGetCurrent()
for value in randomValues {
    let percent = value / percentValue
    let roundedPercent = (percent * divisor).rounded() / divisor
    doublePercents.append(roundedPercent)
}
times.append(CFAbsoluteTimeGetCurrent() - startTime)
sumPercents.append(doublePercents.reduce(0, +))

/*
 *  Лучше использовать алгоритм 3. Не переводит значения в строки, быстрее чем алгоритм 1.
 */
print(times)
print(sumPercents)
