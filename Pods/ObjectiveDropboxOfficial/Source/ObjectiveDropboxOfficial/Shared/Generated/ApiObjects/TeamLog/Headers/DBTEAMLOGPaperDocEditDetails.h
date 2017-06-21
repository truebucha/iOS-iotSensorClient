///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBTEAMLOGPaperDocEditDetails;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `PaperDocEditDetails` struct.
///
/// Edited a Paper doc.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBTEAMLOGPaperDocEditDetails : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// Event unique identifier.
@property (nonatomic, readonly, copy) NSString *eventUuid;

#pragma mark - Constructors

///
/// Full constructor for the struct (exposes all instance variables).
///
/// @param eventUuid Event unique identifier.
///
/// @return An initialized instance.
///
- (instancetype)initWithEventUuid:(NSString *)eventUuid;

- (instancetype)init NS_UNAVAILABLE;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `PaperDocEditDetails` struct.
///
@interface DBTEAMLOGPaperDocEditDetailsSerializer : NSObject

///
/// Serializes `DBTEAMLOGPaperDocEditDetails` instances.
///
/// @param instance An instance of the `DBTEAMLOGPaperDocEditDetails` API
/// object.
///
/// @return A json-compatible dictionary representation of the
/// `DBTEAMLOGPaperDocEditDetails` API object.
///
+ (NSDictionary *)serialize:(DBTEAMLOGPaperDocEditDetails *)instance;

///
/// Deserializes `DBTEAMLOGPaperDocEditDetails` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBTEAMLOGPaperDocEditDetails` API object.
///
/// @return An instantiation of the `DBTEAMLOGPaperDocEditDetails` object.
///
+ (DBTEAMLOGPaperDocEditDetails *)deserialize:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
