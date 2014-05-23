//
//  ViewController.m
//  Rock
//
//  Created by Nick on 20/03/2014.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "DebugViewController.h"
#import "AudioSampler.h"
#import "AudioSettings.h"

@interface DebugViewController () {
    Pulse * _pulse;
    AudioSampler * _sampler;
}

@end

@implementation DebugViewController

/*
 1. Выбрать набор ударных. На выходе – crash, hat, tom1
 
 Для каждого такого инструмента:
 
 2. Выбрать тип интервала – четверти, триоли, случайный интервал.
 
 3. Тип долей – только сильные, только слабые, и те и другие.
 
 4. Есть сдвиг от начала такта – если есть то на какой интервал.
 
 5. Частота (число от 0 до 1, не включая ноль). На каждый такой тик интервала (смотри выше) запускается случайный генератор RAND(1/частота), если выпадает 0 - играем, остальное – не играем.
*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _sampler = [[AudioSampler alloc] init];
    [_sampler setupOnComplete:^{
        
        _pulse = [[Pulse alloc] init];
        [_pulse setTempo:120];
        
        [_pulse setDelegate:self];
        
    }];
    
    
}

- (void) tickWithNumber:(int)tick {
    
    if ( tick == 10 ) {
        [_sampler sendNoteOnToInstrument:kDrums midiKey:44 velocity:100];
    }
    
}

@end
