//
// $Id: CDStructureTable.h,v 1.12 2004/02/03 02:54:38 nygard Exp $
//

//  This file is part of class-dump, a utility for examining the
//  Objective-C segment of Mach-O files.
//  Copyright (C) 1997-1998, 2000-2001, 2004  Steve Nygard

#import <Foundation/NSObject.h>

#import "CDStructureRegistrationProtocol.h"

@class NSMutableArray, NSMutableDictionary, NSMutableSet, NSMutableString;
@class CDClassDump2, CDType, CDSymbolReferences, CDTypeFormatter;

@interface CDStructureTable : NSObject
{
    NSString *name;
    NSString *anonymousBaseName;

    NSMutableDictionary *structuresByName;
    NSMutableDictionary *anonymousStructureCountsByType;
    NSMutableDictionary *anonymousStructuresByType;
    NSMutableDictionary *anonymousStructureNamesByType;

    NSMutableSet *forcedTypedefs;

    NSMutableSet *structureSignatures; // generated during phase 1
    NSMutableArray *structureTypes; // generated during phase 1
    NSMutableDictionary *replacementSignatures; // generated at end of phase 1

    struct {
        unsigned int shouldDebug:1;
    } flags;
}

- (id)init;
- (void)dealloc;

- (NSString *)name;
- (void)setName:(NSString *)newName;

- (NSString *)anonymousBaseName;
- (void)setAnonymousBaseName:(NSString *)newName;

- (BOOL)shouldDebug;
- (void)setShouldDebug:(BOOL)newFlag;

- (void)logPhase1Data;
- (void)finishPhase1;
- (void)logInfo;

- (void)generateNamesForAnonymousStructures;

- (void)appendNamedStructuresToString:(NSMutableString *)resultString classDump:(CDClassDump2 *)aClassDump formatter:(CDTypeFormatter *)aTypeFormatter symbolReferences:(CDSymbolReferences *)symbolReferences;
- (void)appendTypedefsToString:(NSMutableString *)resultString classDump:(CDClassDump2 *)aClassDump formatter:(CDTypeFormatter *)aTypeFormatter symbolReferences:(CDSymbolReferences *)symbolReferences;

- (void)forceTypedefForStructure:(NSString *)typeString;
- (CDType *)replacementForType:(CDType *)aType;
- (NSString *)typedefNameForStructureType:(CDType *)aType;

//- (void)registerStructure:(CDType *)structType name:(NSString *)aName withObject:(id <CDStructureRegistration>)anObject
//             usedInMethod:(BOOL)isUsedInMethod countReferences:(BOOL)shouldCountReferences;

- (void)phase1RegisterStructure:(CDType *)aStructure;
- (BOOL)phase2RegisterStructure:(CDType *)aStructure withObject:(id <CDStructureRegistration>)anObject usedInMethod:(BOOL)isUsedInMethod
                countReferences:(BOOL)shouldCountReferences;

- (void)generateMemberNames;

@end