//
//  ObservablePairwiseTests.swift
//  PublishableItemTests
//
//  Created by Thorn, David on 26.03.20.
//  Copyright © 2020 Thorn, David. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxSwiftExt

class ObservablePairwiseTests: XCTestCase {

    let disposeBag = DisposeBag()

    func testPairwiseObservable() {

        let schedule = TestScheduler(initialClock: 0)
        let stringObservable = PublishSubject<String>()
        let intObservable = PublishSubject<Int>()
        let combinedObservable = Observable.combineLatest(stringObservable, intObservable).pairwise()

        let observer = schedule.createObserver(((String,Int), (String, Int)).self)
        combinedObservable.subscribe(observer).disposed(by: disposeBag)

        schedule.scheduleAt(10) {
            stringObservable.on(.next("One"))
            intObservable.on(.next(1))

            stringObservable.on(.next("Two"))
            intObservable.on(.next(2))

            intObservable.on(.next(3))
        }

        schedule.start()
        schedule.stop()

        /// First event published
        XCTAssertEqual(observer.events.first?.value.element?.0.0, "One")
        XCTAssertEqual(observer.events.first?.value.element?.0.1, 1)

        XCTAssertEqual(observer.events.first?.value.element?.1.0, "Two")
        XCTAssertEqual(observer.events.first?.value.element?.1.1, 1)

        /// Seconed event published
        XCTAssertEqual(observer.events.last?.value.element?.0.0, "Two")
        XCTAssertEqual(observer.events.last?.value.element?.0.1, 2)

        XCTAssertEqual(observer.events.last?.value.element?.1.0, "Two")
        XCTAssertEqual(observer.events.last?.value.element?.1.1, 3)
    }

}
