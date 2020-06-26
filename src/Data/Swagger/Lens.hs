{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE UndecidableInstances #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}
-- |
-- Module:      Data.Swagger.Lens
-- Maintainer:  Nickolay Kudasov <nickolay@getshoptv.com>
-- Stability:   experimental
--
-- Lenses and prisms for Swagger.
module Data.Swagger.Lens where

import Control.Lens
import Data.Aeson (Value)
import Data.Scientific (Scientific)
import Data.Swagger.Internal
import Data.Swagger.Internal.Utils
import Data.Text (Text)

-- * Classy lenses

makeFields ''Swagger
makeFields ''Components
makeFields ''Server
-- conflict with enum of ParamSchema
--makeLensesWith swaggerFieldRules ''ServerVariable
makeFields ''RequestBody
makeFields ''MediaTypeObject
makeFields ''Host
makeFields ''Info
makeFields ''Contact
makeFields ''License
makeLensesWith swaggerFieldRules ''PathItem
makeFields ''Tag
makeFields ''Operation
makeFields ''Param
makeLensesWith swaggerFieldRules ''ParamOtherSchema
makeFields ''Header
makeLensesWith swaggerFieldRules ''Schema
makeFields ''NamedSchema
makeLensesWith swaggerFieldRules ''ParamSchema
makeFields ''Xml
makeLensesWith swaggerFieldRules ''Responses
makeFields ''Response
makeLensesWith swaggerFieldRules ''SecurityScheme
makeFields ''ApiKeyParams
makeFields ''OAuth2Params
makeFields ''ExternalDocs
makeFields ''Encoding
makeFields ''Example
makeFields ''Discriminator

-- * Prisms
-- ** 'ParamAnySchema' prisms
makePrisms ''ParamAnySchema
-- ** 'SecuritySchemeType' prisms
makePrisms ''SecuritySchemeType
-- ** 'Referenced' prisms
makePrisms ''Referenced

-- ** 'SwaggerItems' prisms

_SwaggerItemsArray :: Review (SwaggerItems 'SwaggerKindSchema) [Referenced Schema]
_SwaggerItemsArray
  = unto (\x -> SwaggerItemsArray x)
{- \x -> case x of
      SwaggerItemsPrimitive c p -> Left (SwaggerItemsPrimitive c p)
      SwaggerItemsObject o      -> Left (SwaggerItemsObject o)
      SwaggerItemsArray a       -> Right a
-}

_SwaggerItemsObject :: Review (SwaggerItems 'SwaggerKindSchema) (Referenced Schema)
_SwaggerItemsObject
  = unto (\x -> SwaggerItemsObject x)
{- \x -> case x of
      SwaggerItemsPrimitive c p -> Left (SwaggerItemsPrimitive c p)
      SwaggerItemsObject o      -> Right o
      SwaggerItemsArray a       -> Left (SwaggerItemsArray a)
-}

_SwaggerItemsPrimitive :: forall t p f. (Profunctor p, Bifunctor p, Functor f) => Optic' p f (SwaggerItems t) (Maybe (CollectionFormat t), ParamSchema t)
_SwaggerItemsPrimitive = unto (\(c, p) -> SwaggerItemsPrimitive c p)

-- =============================================================
-- More helpful instances for easier access to schema properties

type instance Index Responses = HttpStatusCode
type instance Index Operation = HttpStatusCode

type instance IxValue Responses = Referenced Response
type instance IxValue Operation = Referenced Response

instance Ixed Responses where ix n = responses . ix n
instance At   Responses where at n = responses . at n

instance Ixed Operation where ix n = responses . ix n
instance At   Operation where at n = responses . at n

type instance Index SecurityDefinitions = Text
type instance IxValue SecurityDefinitions = SecurityScheme

instance Ixed SecurityDefinitions where ix n = (coerced :: Lens' SecurityDefinitions (Definitions SecurityScheme)). ix n
instance At   SecurityDefinitions where at n = (coerced :: Lens' SecurityDefinitions (Definitions SecurityScheme)). at n

instance HasParamSchema NamedSchema (ParamSchema 'SwaggerKindSchema) where paramSchema = schema.paramSchema

-- HasType instances
instance HasType Header (Maybe (SwaggerType ('SwaggerKindNormal Header))) where type_ = paramSchema.type_
instance HasType Schema (Maybe (SwaggerType 'SwaggerKindSchema)) where type_ = paramSchema.type_
instance HasType NamedSchema (Maybe (SwaggerType 'SwaggerKindSchema)) where type_ = paramSchema.type_
instance HasType ParamOtherSchema (Maybe (SwaggerType 'SwaggerKindParamOtherSchema)) where type_ = paramSchema.type_

-- HasDefault instances
instance HasDefault Header (Maybe Value) where default_ = paramSchema.default_
instance HasDefault Schema (Maybe Value) where default_ = paramSchema.default_
instance HasDefault ParamOtherSchema (Maybe Value) where default_ = paramSchema.default_

-- OVERLAPPABLE instances

instance
  {-# OVERLAPPABLE #-}
  HasParamSchema s (ParamSchema t)
  => HasFormat s (Maybe Format) where
  format = paramSchema.format

instance
  {-# OVERLAPPABLE #-}
  HasParamSchema s (ParamSchema t)
  => HasItems s (Maybe (SwaggerItems t)) where
  items = paramSchema.items

instance
  {-# OVERLAPPABLE #-}
  HasParamSchema s (ParamSchema t)
  => HasMaximum s (Maybe Scientific) where
  maximum_ = paramSchema.maximum_

instance {-# OVERLAPPABLE #-} HasParamSchema s (ParamSchema t)
  => HasExclusiveMaximum s (Maybe Bool) where
  exclusiveMaximum = paramSchema.exclusiveMaximum

instance {-# OVERLAPPABLE #-} HasParamSchema s (ParamSchema t)
  => HasMinimum s (Maybe Scientific) where
  minimum_ = paramSchema.minimum_

instance {-# OVERLAPPABLE #-} HasParamSchema s (ParamSchema t)
  => HasExclusiveMinimum s (Maybe Bool) where
  exclusiveMinimum = paramSchema.exclusiveMinimum

instance {-# OVERLAPPABLE #-} HasParamSchema s (ParamSchema t)
  => HasMaxLength s (Maybe Integer) where
  maxLength = paramSchema.maxLength

instance {-# OVERLAPPABLE #-} HasParamSchema s (ParamSchema t)
  => HasMinLength s (Maybe Integer) where
  minLength = paramSchema.minLength

instance {-# OVERLAPPABLE #-} HasParamSchema s (ParamSchema t)
  => HasPattern s (Maybe Text) where
  pattern = paramSchema.pattern

instance {-# OVERLAPPABLE #-} HasParamSchema s (ParamSchema t)
  => HasMaxItems s (Maybe Integer) where
  maxItems = paramSchema.maxItems

instance {-# OVERLAPPABLE #-} HasParamSchema s (ParamSchema t)
  => HasMinItems s (Maybe Integer) where
  minItems = paramSchema.minItems

instance {-# OVERLAPPABLE #-} HasParamSchema s (ParamSchema t)
  => HasUniqueItems s (Maybe Bool) where
  uniqueItems = paramSchema.uniqueItems

instance {-# OVERLAPPABLE #-} HasParamSchema s (ParamSchema t)
  => HasEnum s (Maybe [Value]) where
  enum_ = paramSchema.enum_

instance {-# OVERLAPPABLE #-} HasParamSchema s (ParamSchema t)
  => HasMultipleOf s (Maybe Scientific) where
  multipleOf = paramSchema.multipleOf
