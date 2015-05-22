/****************************************************************************
**
** Copyright (C) 2015 The Qt Company Ltd.
** Contact: http://www.qt.io/licensing/
**
** This file is part of the test suite of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of The Qt Company Ltd nor the names of its
**     contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.2
import QtTest 1.0
import QtQuick.Controls 2.0

TestCase {
    id: testCase
    width: 400
    height: 400
    visible: true
    when: windowShown
    name: "Slider"

    SignalSpy{
        id: pressedSpy
        signalName: "pressedChanged"
    }

    Component {
        id: slider
        Slider { }
    }

    function init() {
        verify(!pressedSpy.target)
        compare(pressedSpy.count, 0)
    }

    function cleanup() {
        pressedSpy.target = null
        pressedSpy.clear()
    }

    function test_defaults() {
        var control = slider.createObject(testCase)
        verify(control)
        verify(control.handle)
        verify(control.track)
        compare(control.value, 0)
        compare(control.position, 0)
        compare(control.visualPosition, 0)
        compare(control.stepSize, 0)
        compare(control.snapMode, AbstractSlider.NoSnap)
        compare(control.pressed, false)
        compare(control.orientation, Qt.Horizontal)
        control.destroy()
    }

    function test_visualPosition() {
        var control = slider.createObject(testCase, {value: 0.25})
        compare(control.value, 0.25)
        compare(control.visualPosition, 0.25)

        control.layoutDirection = Qt.RightToLeft
        compare(control.visualPosition, 0.75)

        control.LayoutMirroring.enabled = true
        compare(control.visualPosition, 0.25)

        control.layoutDirection = Qt.LeftToRight
        compare(control.visualPosition, 0.75)

        control.LayoutMirroring.enabled = false
        compare(control.visualPosition, 0.25)

        control.destroy()
    }

    function test_orientation() {
        var control = slider.createObject(testCase)
        compare(control.orientation, Qt.Horizontal)
        verify(control.width > control.height)
        control.orientation = Qt.Vertical
        compare(control.orientation, Qt.Vertical)
        verify(control.width < control.height)
        control.destroy()
    }

    function test_mouse_data() {
        return [
            { tag: "horizontal", orientation: Qt.Horizontal },
            { tag: "vertical", orientation: Qt.Vertical }
        ]
    }

    function test_mouse(data) {
        var control = slider.createObject(testCase, {orientation: data.orientation})

        pressedSpy.target = control
        verify(pressedSpy.valid)

        mousePress(control, 0, 0, Qt.LeftButton)
        compare(pressedSpy.count, 1)
        compare(control.pressed, true)
        compare(control.value, 0.0)
        compare(control.position, 0.0)

        // mininum on the left in horizontal vs. at the bottom in vertical
        mouseMove(control, -control.width, 2 * control.height, 0, Qt.LeftButton)
        compare(pressedSpy.count, 1)
        compare(control.pressed, true)
        compare(control.value, 0.0)
        compare(control.position, 0.0)

        mouseMove(control, control.width * 0.5, control.height * 0.5, 0, Qt.LeftButton)
        compare(pressedSpy.count, 1)
        compare(control.pressed, true)
        compare(control.value, 0.0)
        verify(control.position, 0.5)

        mouseRelease(control, control.width * 0.5, control.height * 0.5, Qt.LeftButton)
        compare(pressedSpy.count, 2)
        compare(control.pressed, false)
        compare(control.value, 0.5)
        compare(control.position, 0.5)

        mousePress(control, control.width, control.height, Qt.LeftButton)
        compare(pressedSpy.count, 3)
        compare(control.pressed, true)
        compare(control.value, 0.5)
        compare(control.position, 0.5)

        // maximum on the right in horizontal vs. at the top in vertical
        mouseMove(control, control.width * 2, -control.height, 0, Qt.LeftButton)
        compare(pressedSpy.count, 3)
        compare(control.pressed, true)
        compare(control.value, 0.5)
        compare(control.position, 1.0)

        mouseMove(control, control.width * 0.75, control.height * 0.25, 0, Qt.LeftButton)
        compare(pressedSpy.count, 3)
        compare(control.pressed, true)
        compare(control.value, 0.5)
        verify(control.position >= 0.75)

        mouseRelease(control, control.width * 0.25, control.height * 0.75, Qt.LeftButton)
        compare(pressedSpy.count, 4)
        compare(control.pressed, false)
        compare(control.value, control.position)
        verify(control.value <= 0.25 && control.value >= 0.0)
        verify(control.position <= 0.25 && control.position >= 0.0)

        control.destroy()
    }

    function test_keys_data() {
        return [
            { tag: "horizontal", orientation: Qt.Horizontal, decrease: Qt.Key_Left, increase: Qt.Key_Right },
            { tag: "vertical", orientation: Qt.Vertical, decrease: Qt.Key_Down, increase: Qt.Key_Up }
        ]
    }

    function test_keys(data) {
        var control = slider.createObject(testCase, {orientation: data.orientation})

        var pressedCount = 0

        pressedSpy.target = control
        verify(pressedSpy.valid)

        control.forceActiveFocus()
        verify(control.activeFocus)

        control.value = 0.5

        for (var d1 = 1; d1 <= 10; ++d1) {
            keyPress(data.decrease)
            compare(control.pressed, true)
            compare(pressedSpy.count, ++pressedCount)

            compare(control.value, Math.max(0.0, 0.5 - d1 * 0.1))
            compare(control.value, control.position)

            keyRelease(data.decrease)
            compare(control.pressed, false)
            compare(pressedSpy.count, ++pressedCount)
        }

        for (var i1 = 1; i1 <= 20; ++i1) {
            keyPress(data.increase)
            compare(control.pressed, true)
            compare(pressedSpy.count, ++pressedCount)

            compare(control.value, Math.min(1.0, 0.0 + i1 * 0.1))
            compare(control.value, control.position)

            keyRelease(data.increase)
            compare(control.pressed, false)
            compare(pressedSpy.count, ++pressedCount)
        }

        control.stepSize = 0.25

        for (var d2 = 1; d2 <= 10; ++d2) {
            keyPress(data.decrease)
            compare(control.pressed, true)
            compare(pressedSpy.count, ++pressedCount)

            compare(control.value, Math.max(0.0, 1.0 - d2 * 0.25))
            compare(control.value, control.position)

            keyRelease(data.decrease)
            compare(control.pressed, false)
            compare(pressedSpy.count, ++pressedCount)
        }

        for (var i2 = 1; i2 <= 10; ++i2) {
            keyPress(data.increase)
            compare(control.pressed, true)
            compare(pressedSpy.count, ++pressedCount)

            compare(control.value, Math.min(1.0, 0.0 + i2 * 0.25))
            compare(control.value, control.position)

            keyRelease(data.increase)
            compare(control.pressed, false)
            compare(pressedSpy.count, ++pressedCount)
        }

        control.destroy()
    }
}
