//
//  CwlMutexTests.swift
//  CwlUtils
//
//  Created by Matt Gallagher on 2015/02/03.
//  Copyright © 2015 Matt Gallagher ( http://cocoawithlove.com ). All rights reserved.
//
//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
//  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
//  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
//  SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
//  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
//  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
//  IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//

import Foundation
import XCTest
import CwlUtils

class PthreadTests: XCTestCase {
	func testPthreadMutex() {
		let mutex1 = PThreadMutex()
		
		let e1 = expectation(withDescription: "Block1 not invoked")
		mutex1.sync {
			e1.fulfill()
			let reenter: Void? = mutex1.trySync() {
				XCTFail()
			}
			XCTAssert(reenter == nil)
		}
		
		let mutex2 = PThreadMutex(type: .recursive)

		let e2 = expectation(withDescription: "Block2 not invoked")
		let e3 = expectation(withDescription: "Block3 not invoked")
		mutex2.sync {
			e2.fulfill()
			let reenter: Void? = mutex2.trySync() {
				e3.fulfill()
			}
			XCTAssert(reenter != nil)
		}
		
		let e4 = expectation(withDescription: "Block4 not invoked")
		let r = mutex1.sync { n -> Int in
			e4.fulfill()
			let reenter: Void? = mutex1.trySync() {
				XCTFail()
			}
			XCTAssert(reenter == nil)
			return 13
		}
		XCTAssert(r == 13)
		
		waitForExpectations(withTimeout: 0, handler: nil)
	}
}
