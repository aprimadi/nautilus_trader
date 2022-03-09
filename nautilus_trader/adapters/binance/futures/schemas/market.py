# -------------------------------------------------------------------------------------------------
#  Copyright (C) 2015-2022 Nautech Systems Pty Ltd. All rights reserved.
#  https://nautechsystems.io
#
#  Licensed under the GNU Lesser General Public License Version 3.0 (the "License");
#  You may not use this file except in compliance with the License.
#  You may obtain a copy of the License at https://www.gnu.org/licenses/lgpl-3.0.en.html
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# -------------------------------------------------------------------------------------------------

from typing import List, Optional

import msgspec

from nautilus_trader.adapters.binance.common.enums import BinanceExchangeFilterType
from nautilus_trader.adapters.binance.common.enums import BinanceRateLimitInterval
from nautilus_trader.adapters.binance.common.enums import BinanceRateLimitType
from nautilus_trader.adapters.binance.common.enums import BinanceSymbolFilterType
from nautilus_trader.adapters.binance.futures.enums import BinanceFuturesContractStatus
from nautilus_trader.adapters.binance.futures.enums import BinanceFuturesOrderType
from nautilus_trader.adapters.binance.futures.enums import BinanceFuturesTimeInForce


class BinanceExchangeFilter(msgspec.Struct):
    """Response 'inner struct' from `Binance` GET /fapi/v1/exchangeInfo."""

    filterType: BinanceExchangeFilterType
    maxNumOrders: Optional[int] = None
    maxNumAlgoOrders: Optional[int] = None


class BinanceSymbolFilter(msgspec.Struct):
    """Response 'inner struct' from `Binance` GET /fapi/v1/exchangeInfo."""

    filterType: BinanceSymbolFilterType
    minPrice: Optional[str] = None
    maxPrice: Optional[str] = None
    tickSize: Optional[str] = None
    multiplierUp: Optional[str] = None
    multiplierDown: Optional[str] = None
    avgPriceMins: Optional[int] = None
    bidMultiplierUp: Optional[str] = None
    bidMultiplierDown: Optional[str] = None
    askMultiplierUp: Optional[str] = None
    askMultiplierDown: Optional[str] = None
    minQty: Optional[str] = None
    maxQty: Optional[str] = None
    stepSize: Optional[str] = None
    minNotional: Optional[str] = None
    applyToMarket: Optional[bool] = None
    limit: Optional[int] = None
    maxNumOrders: Optional[int] = None
    maxNumAlgoOrders: Optional[int] = None
    maxNumIcebergOrders: Optional[int] = None
    maxPosition: Optional[str] = None


class BinanceRateLimit(msgspec.Struct):
    """Response 'inner struct' from `Binance` GET /fapi/v1/exchangeInfo."""

    rateLimitType: BinanceRateLimitType
    interval: BinanceRateLimitInterval
    intervalNum: int
    limit: int


class BinanceFuturesAsset(msgspec.Struct):
    """Response 'inner struct' from `Binance` Futures GET /fapi/v1/exchangeInfo."""

    asset: str
    marginAvailable: bool
    autoAssetExchange: str


class BinanceFuturesSymbolInfo(msgspec.Struct):
    """Response 'inner struct' from `Binance` Futures GET /fapi/v1/exchangeInfo."""

    symbol: str
    pair: str
    contractType: str  # Can be '' empty string
    deliveryDate: int
    onboardDate: int
    status: BinanceFuturesContractStatus
    maintMarginPercent: str
    requiredMarginPercent: str
    baseAsset: str
    quoteAsset: str
    marginAsset: str
    pricePrecision: int
    quantityPrecision: int
    baseAssetPrecision: int
    quotePrecision: int
    underlyingType: str
    underlyingSubType: List[str]
    settlePlan: int
    triggerProtect: str
    liquidationFee: str
    marketTakeBound: str
    filters: List[BinanceSymbolFilter]
    orderTypes: List[BinanceFuturesOrderType]
    timeInForce: List[BinanceFuturesTimeInForce]


class BinanceFuturesExchangeInfo(msgspec.Struct):
    """Response from `Binance` Futures GET /fapi/v1/exchangeInfo."""

    timezone: str
    serverTime: int
    rateLimits: List[BinanceRateLimit]
    exchangeFilters: List[BinanceExchangeFilter]
    assets: List[BinanceFuturesAsset]
    symbols: List[BinanceFuturesSymbolInfo]