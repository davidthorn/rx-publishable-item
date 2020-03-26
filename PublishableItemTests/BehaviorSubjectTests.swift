//
//  BehaviorSubjectTests.swift
//  PublishableItemTests
//
//  Created by Thorn, David on 26.03.20.
//  Copyright © 2020 Thorn, David. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class BehaviorSubjectTests: XCTestCase {

    enum MockError: Error {
        case error
    }

    let disposeBag = DisposeBag()

    func valueIs(value: String, subject: BehaviorSubject<String>) {
        do {
            let subjectValue = try subject.value()
            XCTAssertEqual(subjectValue, value)
        } catch {
            XCTFail("This test should not fail")
        }
    }

    func testBehaviorSubject() {

        let subject = BehaviorSubject<String>(value: "One")
        valueIs(value: "One", subject: subject)
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(String.self)
        subject.subscribe(observer).disposed(by: disposeBag)

        scheduler.scheduleAt(10) {
            subject.on(.next("Two"))
            self.valueIs(value: "Two", subject: subject)
        }

        scheduler.scheduleAt(20) {
            subject.onNext("Three")
            self.valueIs(value: "Three", subject: subject)
        }

        scheduler.start()

        let recorded: [Recorded<Event<String>>] = [
            .next(0, "One"),
            .next(10, "Two"),
            .next(20, "Three")
        ]

        XCTAssertEqual(observer.events, recorded)
        XCTAssertNoThrow(try subject.value())
        valueIs(value: "Three", subject: subject)
    }

    func testCompletedBehaviorSubject() {

        let subject = BehaviorSubject<String>(value: "One")
        valueIs(value: "One", subject: subject)
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(String.self)
        subject.subscribe(observer).disposed(by: disposeBag)

        scheduler.scheduleAt(10) {
            subject.on(.next("Two"))
            self.valueIs(value: "Two", subject: subject)
        }

        scheduler.scheduleAt(20) {
            subject.onNext("Three")
            self.valueIs(value: "Three", subject: subject)
        }

        scheduler.scheduleAt(30) {
            subject.on(.completed)
            self.valueIs(value: "Three", subject: subject)
        }

        scheduler.scheduleAt(40) {
            subject.onNext("Three")
            self.valueIs(value: "Three", subject: subject)
        }

        scheduler.start()

        let recorded: [Recorded<Event<String>>] = [
            .next(0, "One"),
            .next(10, "Two"),
            .next(20, "Three"),
            .completed(30)

        ]

        XCTAssertEqual(observer.events, recorded)
        XCTAssertNoThrow(try subject.value())
        valueIs(value: "Three", subject: subject)
    }

    func testErrorBehaviorSubject() {

        let subject = BehaviorSubject<String>(value: "One")
        valueIs(value: "One", subject: subject)
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(String.self)
        subject.subscribe(observer).disposed(by: disposeBag)

        scheduler.scheduleAt(10) {
            subject.on(.next("Two"))
            self.valueIs(value: "Two", subject: subject)
        }

        scheduler.scheduleAt(20) {
            subject.onNext("Three")
            self.valueIs(value: "Three", subject: subject)
        }

        scheduler.scheduleAt(30) {
            self.valueIs(value: "Three", subject: subject)
            subject.onError(MockError.error)
        }

        scheduler.scheduleAt(40) {
            subject.onNext("Three")
        }

        scheduler.start()

        let recorded: [Recorded<Event<String>>] = [
            .next(0, "One"),
            .next(10, "Two"),
            .next(20, "Three"),
            .error(30, MockError.error),
        ]

        XCTAssertEqual(observer.events, recorded)
        XCTAssertThrowsError(try subject.value())
    }

}
