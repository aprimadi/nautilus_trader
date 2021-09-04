# -------------------------------------------------------------------------------------------------
#  Copyright (C) 2015-2021 Nautech Systems Pty Ltd. All rights reserved.
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

from decimal import Decimal

from nautilus_trader.core.correctness cimport Condition
from nautilus_trader.model.c_enums.account_type cimport AccountTypeParser
from nautilus_trader.model.events.account cimport AccountState
from nautilus_trader.model.instruments.base cimport Instrument
from nautilus_trader.model.objects cimport AccountBalance


cdef class Account:
    """
    The base class for all trading accounts.
    """

    def __init__(
        self,
        AccountState event,
        bint calculate_account_state,
    ):
        """
        Initialize a new instance of the ``Account`` class.

        Parameters
        ----------
        event : AccountState
            The initial account state event.
        calculate_account_state : bool
            If the account state should be calculated from order fills.

        Raises
        ------
        ValueError
            If account_type is not equal to event.account_type.

        """
        Condition.not_none(event, "event")

        self.id = event.account_id
        self.type = event.account_type
        self.base_currency = event.base_currency
        self.calculate_account_state = calculate_account_state

        self._starting_balances = {b.currency: b.total for b in event.balances}
        self._events = [event]  # type: list[AccountState]
        self._balances = {}     # type: dict[Currency, AccountBalance]
        self._commissions = {}  # type: dict[Currency, Money]

        self.update_balances(event.balances)

    def __eq__(self, Account other) -> bool:
        return self.id.value == other.id.value

    def __hash__(self) -> int:
        return hash(self.id.value)

    def __repr__(self) -> str:
        cdef str base_str = self.base_currency.code if self.base_currency is not None else None
        return (f"{type(self).__name__}("
                f"id={self.id.value}, "
                f"type={AccountTypeParser.to_str(self.type)}, "
                f"base={base_str})")

# -- QUERIES ---------------------------------------------------------------------------------------

    cdef AccountState last_event_c(self):
        return self._events[-1]  # Always at least one event

    cdef list events_c(self):
        return self._events.copy()

    cdef int event_count_c(self):
        return len(self._events)

    @property
    def last_event(self):
        """
        The accounts last state event.

        Returns
        -------
        AccountState

        """
        return self.last_event_c()

    @property
    def events(self):
        """
        All events received by the account.

        Returns
        -------
        list[AccountState]

        """
        return self.events_c()

    @property
    def event_count(self):
        """
        The count of events.

        Returns
        -------
        int

        """
        return self.event_count_c()

    cpdef list currencies(self):
        """
        Return the account currencies.

        Returns
        -------
        list[Currency]

        """
        return list(self._balances.keys())

    cpdef dict starting_balances(self):
        """
        Return the account starting balances.

        Returns
        -------
        dict[Currency, Money]

        """
        return self._starting_balances.copy()

    cpdef dict balances(self):
        """
        Return the account balances totals.

        Returns
        -------
        dict[Currency, Money]

        """
        return self._balances.copy()

    cpdef dict balances_total(self):
        """
        Return the account balances totals.

        Returns
        -------
        dict[Currency, Money]

        """
        return {c: b.total for c, b in self._balances.items()}

    cpdef dict balances_free(self):
        """
        Return the account balances free.

        Returns
        -------
        dict[Currency, Money]

        """
        return {c: b.free for c, b in self._balances.items()}

    cpdef dict balances_locked(self):
        """
        Return the account balances locked.

        Returns
        -------
        dict[Currency, Money]

        """
        return {c: b.locked for c, b in self._balances.items()}

    cpdef dict commissions(self):
        """
        Return the total commissions for the account.
        """
        return self._commissions.copy()

    cpdef AccountBalance balance(self, Currency currency=None):
        """
        Return the current account balance total.

        For multi-currency accounts, specify the currency for the query.

        Parameters
        ----------
        currency : Currency, optional
            The currency for the query. If `None` then will use the default
            currency (if set).

        Returns
        -------
        AccountBalance or None

        Raises
        ------
        ValueError
            If currency is `None` and base_currency is `None`.

        Warnings
        --------
        Returns `None` if there is no applicable information for the query,
        rather than `Money` of zero amount.

        """
        if currency is None:
            currency = self.base_currency
        Condition.not_none(currency, "currency")

        return self._balances.get(currency)

    cpdef Money balance_total(self, Currency currency=None):
        """
        Return the current account balance total.

        For multi-currency accounts, specify the currency for the query.

        Parameters
        ----------
        currency : Currency, optional
            The currency for the query. If `None` then will use the default
            currency (if set).

        Returns
        -------
        Money or None

        Raises
        ------
        ValueError
            If currency is `None` and base_currency is `None`.

        Warnings
        --------
        Returns `None` if there is no applicable information for the query,
        rather than `Money` of zero amount.

        """
        if currency is None:
            currency = self.base_currency
        Condition.not_none(currency, "currency")

        cdef AccountBalance balance = self._balances.get(currency)
        if balance is None:
            return None
        return balance.total

    cpdef Money balance_free(self, Currency currency=None):
        """
        Return the account balance free.

        For multi-currency accounts, specify the currency for the query.

        Parameters
        ----------
        currency : Currency, optional
            The currency for the query. If `None` then will use the default
            currency (if set).

        Returns
        -------
        Money or None

        Raises
        ------
        ValueError
            If currency is `None` and base_currency is `None`.

        Warnings
        --------
        Returns `None` if there is no applicable information for the query,
        rather than `Money` of zero amount.

        """
        if currency is None:
            currency = self.base_currency
        Condition.not_none(currency, "currency")

        cdef AccountBalance balance = self._balances.get(currency)
        if balance is None:
            return None
        return balance.free

    cpdef Money balance_locked(self, Currency currency=None):
        """
        Return the account balance locked.

        For multi-currency accounts, specify the currency for the query.

        Parameters
        ----------
        currency : Currency, optional
            The currency for the query. If `None` then will use the default
            currency (if set).

        Returns
        -------
        Money or None

        Raises
        ------
        ValueError
            If currency is `None` and base_currency is `None`.

        Warnings
        --------
        Returns `None` if there is no applicable information for the query,
        rather than `Money` of zero amount.

        """
        if currency is None:
            currency = self.base_currency
        Condition.not_none(currency, "currency")

        cdef AccountBalance balance = self._balances.get(currency)
        if balance is None:
            return None
        return balance.locked

    cpdef Money commission(self, Currency currency):
        """
        Return the total commissions for the given currency.

        Parameters
        ----------
        currency : Currency
            The currency for the commission.

        Returns
        -------
        Money or None

        """
        return self._commissions.get(currency)

# -- COMMANDS --------------------------------------------------------------------------------------

    cpdef void apply(self, AccountState event) except *:
        """
        Apply the given account event to the account.

        Parameters
        ----------
        event : AccountState
            The account event to apply.

        Warnings
        --------
        System method (not intended to be called by user code).

        """
        Condition.not_none(event, "event")
        Condition.equal(event.account_id, self.id, "self.id", "event.account_id")
        Condition.equal(event.base_currency, self.base_currency, "self.base_currency", "event.base_currency")

        if self.base_currency:
            # Single-currency account
            Condition.true(len(event.balances) == 1, "single-currency account has multiple currency update")
            Condition.equal(event.balances[0].currency, self.base_currency, "event.balances[0].currency", "self.base_currency")

        self._events.append(event)
        self.update_balances(event.balances)

    cpdef void update_balances(self, list balances) except *:
        """
        Update the account balances.

        There is no guarantee that every account currency is included in the
        given balances, therefore we only update included balances.

        Parameters
        ----------
        balances : list[AccountBalance]

        """
        Condition.not_none(balances, "balances")
        Condition.not_empty(balances, "balances")

        cdef AccountBalance balance
        for balance in balances:
            self._balances[balance.currency] = balance

    cpdef void update_commissions(self, Money commission) except *:
        """
        Update the commissions.

        Can be negative which represents credited commission.

        Parameters
        ----------
        commission : Money
            The commission to update with.

        Warnings
        --------
        System method (not intended to be called by user code).

        """
        Condition.not_none(commission, "commission")

        # Increment total commissions
        if commission.as_decimal() == 0:
            return  # Nothing to update

        cdef Currency currency = commission.currency
        total_commissions: Decimal = self._commissions.get(currency, Decimal(0))
        self._commissions[currency] = Money(total_commissions + commission, currency)

    cpdef void update_margin_init(self, InstrumentId instrument_id, Money margin_init) except *:
        """Abstract method (implement in subclass)."""
        raise NotImplementedError("method must be implemented in the subclass")

    cpdef void clear_margin_init(self, InstrumentId instrument_id) except *:
        """Abstract method (implement in subclass)."""
        raise NotImplementedError("method must be implemented in the subclass")

    cdef void _recalculate_balance(self, Currency currency) except *:
        raise NotImplementedError("method must be implemented in the subclass")

# -- CALCULATIONS ----------------------------------------------------------------------------------

    cpdef Money calculate_commission(
        self,
        Instrument instrument,
        Quantity last_qty,
        last_px: Decimal,
        LiquiditySide liquidity_side,
        bint inverse_as_quote=False,
    ):
        """Abstract method (implement in subclass)."""
        raise NotImplementedError("method must be implemented in the subclass")

    cpdef list calculate_pnls(
        self,
        Instrument instrument,
        Position position,  # Can be None
        OrderFilled fill,
    ):
        """Abstract method (implement in subclass)."""
        raise NotImplementedError("method must be implemented in the subclass")