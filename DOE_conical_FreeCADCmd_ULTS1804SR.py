# -*- coding: utf-8 -*-
# copyright, GPL
# Qingfeng Xia  Oxford, modified by Sourav Mandal @ULiege, Belgium

from __future__ import print_function, division

"""
simple script to let FreeCAD generate CAD file by commandline

############################## use in FreeCAD GUI ##############################
FreeCAD GUI will boot up, but it is good to debug the script, see where the script stuck.
If everything goes well, this script will close the FreeCAD gui, as requested in batch mode automation
1. paste this into FreeCAD python console:
exec(open('/home/qxia/Documents/StepMultiphysics/fc_bool_fragments.py').read())
2. or make this script as FreeCAD Macro (*.FCMacro), but it takes extra step in GUI
3. or in terminal:  freecad this_script.py  (this script will be run in twice), it is recommended to run in Editor mode as below.
this script seems run twice in gui mode, The reason is not known yet.   run in GUI editor mode / console mode instead
4. or editor mode:  in FreeCAD GUI, File->Open... open this file into python editor windows and then run this script uisng Macro run toolbar
 in this mode, error or exception can show its occuring line number in console/status bar

############################## use in console mode #############################
For some cases, long time computation will freeze the desktop in GUI mode
To be able to run in both GUI and console mode, using this conditioanal script
`if FreeCAD.GuiUp: `
to run in console mode without GUI:  `freecadcmd this_script.py` can avoid this situation
`python3 -m  this_script.py`  # uisng python2 if you FreeCAD is built with python2,
this may fail because python files in each module are not loaded into search path!
"""


import sys
import os.path

## this section is needed only if called directly from `python3 -m  this_script.py`
if os.path.exists('/usr/lib/freecad/lib'):
    print('found FreeCAD stable  on system')
    sys.path.append('/usr/lib/freecad/lib')
elif os.path.exists('/usr/lib/freecad-daily/lib'):
    sys.path.append('/usr/lib/freecad-daily/lib')
    print('found FreeCAD-daily on system')
else:
    print('no FreeCAD stable or daily build is found on system, please install')

#sys.path.append('/Users/sourav/Applications/FreeCAD.app/Contents/Resources/bin/FreeCADCmd')
sys.path.append('/usr/lib/freecad/bin/FreeCADCmd')
#elif os.path.exists('/usr/lib/freecad-daily/lib'):#/Applications
#sys.path.append('/Users/sourav/Applications/FreeCAD.app/Contents/Resources/bin/FreeCAD')
sys.path.append('/usr/lib/freecad/bin/FreeCAD')

import FreeCAD #freeCAD, if `FreeCAD` fails, on MacOS
import FreeCAD as App
import Part
if FreeCAD.GuiUp:  # use this cond to enclosure all Gui commands
    import FreeCADGui as Gui  # it is better to keep the GUI

###############copied from FreeCAD recorded macro file##############

App.newDocument("Unnamed")  # in GUI mode, setActiveDocument() is done automatically
if not FreeCAD.GuiUp:
    App.setActiveDocument("Unnamed")
    App.ActiveDocument=App.getDocument("Unnamed")
    #Gui.ActiveDocument=Gui.getDocument("Unnamed")
else:
    Gui.activateWorkbench("PartWorkbench")

# exec(open('/Users/sourav/Applications/FreeCAD.app/Contents/Resources/data/Mod/Start/StartPage/LoadNew.py').read())
# App.setActiveDocument("Unnamed")
# App.ActiveDocument=App.getDocument("Unnamed")
# Gui.ActiveDocument=Gui.getDocument("Unnamed")

import Part
import Sketcher
#Create a Spreadsheet object and
#in the first row, create the names of parameters to be input
App.activeDocument().addObject('Spreadsheet::Sheet','Spreadsheet')
App.ActiveDocument.Spreadsheet.set('B1', 'Rbig')
App.ActiveDocument.Spreadsheet.set('C1', 'Rsmall')
App.ActiveDocument.Spreadsheet.set('D1', 'Rmiddle')
App.ActiveDocument.Spreadsheet.set('E1', 'Lupper')
App.ActiveDocument.Spreadsheet.set('F1', 'Llower')
App.ActiveDocument.recompute()

#Now input the geometry parameters values in corresponding coloumn
App.ActiveDocument.Spreadsheet.setAlias('B2', 'Rbig')
App.ActiveDocument.Spreadsheet.set('B2', '=5.0mm')
App.ActiveDocument.Spreadsheet.setAlias('C2', 'Rsmall')
App.ActiveDocument.Spreadsheet.set('C2', '=1.0mm')
App.ActiveDocument.Spreadsheet.setAlias('D2', 'Rmiddle')
App.ActiveDocument.Spreadsheet.set('D2', '=2.0mm')
App.ActiveDocument.Spreadsheet.setAlias('E2', 'Lupper')
App.ActiveDocument.Spreadsheet.set('E2', '=4.0mm')
App.ActiveDocument.Spreadsheet.setAlias('F2', 'Llower')
App.ActiveDocument.Spreadsheet.set('F2', '=5.0mm')
App.ActiveDocument.recompute()

# Adding the constraints
App.activeDocument().addObject('Sketcher::SketchObject','Sketch_conical')
geoList = []
geoList.append(Part.LineSegment(App.Vector(0,0,0),App.Vector(1,0,0)))
geoList.append(Part.LineSegment(App.Vector(1,0,0),App.Vector(2,5,0)))
geoList.append(Part.LineSegment(App.Vector(2,5,0),App.Vector(5,9,0)))
geoList.append(Part.LineSegment(App.Vector(5,9,0),App.Vector(0,9,0)))
geoList.append(Part.LineSegment(App.Vector(0,9,0),App.Vector(0,0,0)))
App.ActiveDocument.Sketch_conical.addGeometry(geoList,False)
conList = []
conList.append(Sketcher.Constraint('Coincident',1,2,2,1))
conList.append(Sketcher.Constraint('Coincident',3,1,4,1))
conList.append(Sketcher.Constraint('Coincident',1,1,0,2))
conList.append(Sketcher.Constraint('Coincident',3,2,2,2))
conList.append(Sketcher.Constraint('Coincident',4,2,0,1))
conList.append(Sketcher.Constraint('Coincident',0,1,-1,1))
conList.append(Sketcher.Constraint('Horizontal',0))
conList.append(Sketcher.Constraint('Horizontal',3))
conList.append(Sketcher.Constraint('Vertical',4))
App.ActiveDocument.Sketch_conical.addConstraint(conList)
App.ActiveDocument.Sketch_conical.addConstraint(Sketcher.Constraint('DistanceX',3,5.0))
App.getDocument('Unnamed').Sketch_conical.setExpression('Constraints[0]', u'Spreadsheet.B2')
App.ActiveDocument.Sketch_conical.addConstraint(Sketcher.Constraint('DistanceX',0,1.0))
App.getDocument('Unnamed').Sketch_conical.setExpression('Constraints[1]', u'Spreadsheet.C2')
App.ActiveDocument.Sketch_conical.addConstraint(Sketcher.Constraint('Distance',4,8.435205))
App.getDocument('Unnamed').Sketch_conical.setExpression('Constraints[11]', u'Spreadsheet.E2 + Spreadsheet.F2')
App.ActiveDocument.Sketch_conical.addGeometry(Part.LineSegment(App.Vector(3.465813,3.822884,0),App.Vector(-2.693190,3.822884,0)),True)
App.ActiveDocument.Sketch_conical.addConstraint(Sketcher.Constraint('Coincident',5,1,1,2))
App.ActiveDocument.Sketch_conical.addConstraint(Sketcher.Constraint('PointOnObject',5,2,4))
App.ActiveDocument.Sketch_conical.addConstraint(Sketcher.Constraint('Distance',5,2,0,1,3.822884))
App.getDocument('Unnamed').Sketch_conical.setExpression('Constraints[14]', u'Spreadsheet.F2')
App.ActiveDocument.Sketch_conical.addConstraint(Sketcher.Constraint('Horizontal',5))
App.ActiveDocument.Sketch_conical.addConstraint(Sketcher.Constraint('Distance',5,3.465813))
App.getDocument('Unnamed').Sketch_conical.setExpression('Constraints[16]', u'Spreadsheet.D2')
App.ActiveDocument.recompute()

#Extruding along the Z axis in `PartDesignWorkbench`
f = FreeCAD.getDocument('Unnamed').addObject('Part::Extrusion', 'Extrude_conical')
f = App.getDocument('Unnamed').getObject('Extrude_conical')
f.Base = App.getDocument('Unnamed').getObject('Sketch_conical')
f.DirMode = "Normal"
f.DirLink = None
f.LengthFwd = 25.000000000000000
f.LengthRev = 0.000000000000000
f.Solid = True
f.Reversed = False
f.Symmetric = True
f.TaperAngle = 0.000000000000000
f.TaperAngleRev = 0.000000000000000
FreeCAD.getDocument("Unnamed").getObject("Extrude_conical").LengthFwd = '2 mm'
# App.getDocument('Unnamed').Extrude_conical.setExpression('LengthFwd', u'Spreadsheet.beadDomainZ')
App.ActiveDocument.recompute()

#Exporting the `Extrude_conical`
__objs__=[]
__objs__.append(FreeCAD.getDocument("Unnamed").getObject("Extrude_conical"))
# import ImportGui
# ImportGui.export(__objs__,u"/Users/sourav/ownCloud/FreeCAD/FAB_FreeCADCmd.step")
# del __objs__
#
# __objs__=[]
# __objs__.append(FreeCAD.getDocument("Unnamed").getObject("BooleanFragments"))
import Part
Part.export(__objs__,u"Extrude_conical.stl")
Part.export(__objs__,u"Extrude_conical.brep")
del __objs__

print('this script complete sucessfully')

######################### end of paste ##############################
# '''
# exit FreeCAD, only after you have done the debugging
FreeCAD.closeDocument('Unnamed')
if FreeCAD.GuiUp:
    Gui.doCommand('exit(0)')  # another way to exit
# '''
