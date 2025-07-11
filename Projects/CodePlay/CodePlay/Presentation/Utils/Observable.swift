//
//  Observable.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/11/25.
//

import Foundation

final class Observable<Value> {
    struct Observer<T> {
        weak var observer: AnyObject? // AnyObject : 모든 클래스 타입을 저장
        let block: (T) -> Void
    }

    private var observers = [Observer<Value>]()

    var value: Value {
        didSet {
            notifyObservers()
            cleanupObservers()
        } // value의 값이 변경된 직후에 호출
    }

    init(_ value: Value) {
        self.value = value
    }

    func observe(on observer: AnyObject, observerBlock: @escaping (Value) -> Void) {
        observers.append(Observer(observer: observer, block: observerBlock))
        observerBlock(value)
    }

    func remove(observer: AnyObject) {
        observers = observers.filter { $0.observer !== observer }
    }

    private func notifyObservers() {
        for observer in observers {
            observer.block(value)
        }
    }
    
    private func cleanupObservers() {
        observers = observers.filter { $0.observer != nil }
    }
}
