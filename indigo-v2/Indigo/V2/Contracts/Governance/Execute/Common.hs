{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}

module Indigo.V2.Contracts.Governance.Execute.Common
  ( ExecuteParams (..),
    Upgrade (Upgrade, uId, uContent, uPassedTime, uVotingEndTime, uProtocolVersion, uTreasuryWithdrawal),
    ExecuteRedeemer (Execute),
    ExecuteScript,
  )
where

import Data.Aeson (FromJSON, ToJSON)
import GHC.Generics (Generic)
import Indigo.V2.Contracts.Governance.Gov.Common (ProposalContent, TreasuryWithdrawal)
import Ledger qualified
import Ledger.Typed.Scripts qualified as TScripts
import Ledger.Value qualified as Value
import Plutus.V1.Ledger.Api (ValidatorHash)
import PlutusTx qualified
import PlutusTx.Prelude (Integer, Maybe)
import Prelude qualified as P

data ExecuteParams = ExecuteParams
  { govNFT :: Value.AssetClass,
    upgradeToken :: Value.AssetClass,
    -- | NFT identifying authentic iAsset output in CDP
    iAssetToken :: Value.AssetClass,
    stabilityPoolToken :: Value.AssetClass,
    versionRecordToken :: Value.AssetClass,
    cdpValHash :: ValidatorHash,
    sPoolValHash :: ValidatorHash,
    versionRegistryValHash :: ValidatorHash,
    treasuryValHash :: ValidatorHash,
    -- | Max amount of interest periods that can be stored in IAsset datum.
    -- Remove the oldest rate in case the number of rates for the given IAsset should be exceeded.
    maxInterestPeriods :: Integer,
    -- | AssetClass of INDY token.
    indyToken :: Value.AssetClass
  }
  deriving (Generic, P.Show, ToJSON, FromJSON, P.Eq, P.Ord)

PlutusTx.makeLift ''ExecuteParams
PlutusTx.makeIsDataIndexed ''ExecuteParams [('ExecuteParams, 0)]

data Upgrade = Upgrade
  { uId :: Integer,
    uContent :: ProposalContent,
    uPassedTime :: Ledger.POSIXTime,
    uVotingEndTime :: Ledger.POSIXTime,
    uProtocolVersion :: Integer,
    -- | Value proposed to be withdrawn from treasury as part of the proposal.
    uTreasuryWithdrawal :: Maybe TreasuryWithdrawal
  }

PlutusTx.makeLift ''Upgrade
PlutusTx.makeIsDataIndexed ''Upgrade [('Upgrade, 0)]

data ExecuteRedeemer = Execute
  deriving stock (P.Eq, P.Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

PlutusTx.makeLift ''ExecuteRedeemer
PlutusTx.makeIsDataIndexed ''ExecuteRedeemer [('Execute, 0)]

data ExecuteScript

instance TScripts.ValidatorTypes ExecuteScript where
  type DatumType ExecuteScript = Upgrade
  type RedeemerType ExecuteScript = ExecuteRedeemer