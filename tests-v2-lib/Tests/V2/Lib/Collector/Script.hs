{-# LANGUAGE TemplateHaskell #-}

module Tests.V2.Lib.Collector.Script (CollectorScript, collectorScript, collectorValidatorHash) where

import Indigo.V2.Contracts.Collector.Common
  ( CollectorRedeemer,
    CollectorScriptParams,
  )
import Ledger qualified
import Plutus.Model.V2 (TypedValidator, mkTypedValidator')
import Plutus.Script.Utils.V2.Scripts qualified as Scripts
import Plutus.Script.Utils.V2.Typed.Scripts.Validators (UntypedValidator)
import Plutus.V2.Ledger.Api qualified as V2
import PlutusTx qualified
import PlutusTx.Prelude
import Tests.Common.LoadValidatorUtil (loadValidatorUsingEnvVar)

type CollectorScript = TypedValidator () CollectorRedeemer

collectorValidatorHash :: CollectorScriptParams -> Ledger.ValidatorHash
collectorValidatorHash params = Scripts.validatorHash $ untypedCollectorScript params

untypedCollectorScript :: CollectorScriptParams -> V2.Validator
untypedCollectorScript params =
  V2.Validator $
    Ledger.applyArguments
      (Ledger.getValidator (V2.mkValidatorScript compiledValidateCollector))
      [V2.toData params]

collectorScript :: CollectorScriptParams -> CollectorScript
collectorScript = mkTypedValidator' . untypedCollectorScript

compiledValidateCollector :: PlutusTx.CompiledCode UntypedValidator
compiledValidateCollector =
  $$(loadValidatorUsingEnvVar "collector.named-debruijn")