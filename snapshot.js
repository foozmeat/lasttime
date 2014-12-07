#import "SnapshotHelper.js"

var target = UIATarget.localTarget();

captureLocalizedScreenshot("01-Lists")

target.frontMostApp().navigationBar().buttons()[1].tap();
target.delay(1)
target.frontMostApp().mainWindow().tableViews()[1].tapWithOptions({tapOffset:{x:0.50, y:0.20}});
captureLocalizedScreenshot("02-Timeline")
target.delay(1)

target.frontMostApp().navigationBar().buttons()[1].tap();
target.delay(1)
target.frontMostApp().mainWindow().tableViews()[1].tapWithOptions({tapOffset:{x:0.50, y:0.13}});
target.delay(1)
target.frontMostApp().mainWindow().tableViews()[0].cells()["Health"].tap();
target.delay(1)
captureLocalizedScreenshot("03-Event_List")

target.frontMostApp().mainWindow().tableViews()[0].cells()["Running"].tap();
target.delay(1)
captureLocalizedScreenshot("04-Event_Detail")

target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().mainWindow().tableViews()[0].cells()["Car"].tap();
target.delay(1)
target.frontMostApp().navigationBar().rightButton().tap();
target.delay(1)
target.frontMostApp().mainWindow().tableViews()[0].cells()["Checked Oil"].tap();
target.delay(2)
captureLocalizedScreenshot("05-Edit_Event")
target.delay(1)
