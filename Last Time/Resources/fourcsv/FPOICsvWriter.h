//
//  FPOICsvWriter.h
//  FourCSV
//
//  Created by Matthias Bartelmeß on 13.01.10.
//  Copyright 2010 fourplusone. All rights reserved.
//


@protocol FPOICsvWriter

-(id)initWithFileHandle:(NSFileHandle *)fh;
-(void)writeRow:(NSArray *)row;
-(void)writeRows:(NSArray *)rows;

@end
