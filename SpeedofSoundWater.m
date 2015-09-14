function speed=SpeedofSoundWater(Temperature)
 Xcoeff =  [0.00000000314643 ,-0.000001478,0.000334199,-0.0580852,5.03711,1402.32];
speed = polyval(Xcoeff,Temperature);
