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

from nautilus_trader.execution.reports import ExecutionStateReport
from nautilus_trader.execution.reports import OrderStateReport
from nautilus_trader.execution.reports import PositionStateReport
from nautilus_trader.model.enums import OrderState
from nautilus_trader.model.enums import PositionSide
from nautilus_trader.model.identifiers import ClientOrderId
from nautilus_trader.model.identifiers import OrderId
from nautilus_trader.model.objects import Quantity
from tests.test_kit.stubs import TestStubs
from tests.test_kit.stubs import UNIX_EPOCH


AUDUSD_SIM = TestStubs.audusd_id()


class TestExecutionStateReport:
    def test_instantiate_report(self):
        # Arrange
        client = "IB"
        account_id = TestStubs.account_id()

        # Act
        report = ExecutionStateReport(
            client=client,
            account_id=account_id,
            timestamp=UNIX_EPOCH,
        )

        # Assert
        assert report.client == client
        assert report.account_id == account_id
        assert report.timestamp == UNIX_EPOCH
        assert report.order_states() == {}
        assert report.position_states() == {}

    def test_add_order_state_report(self):
        # Arrange
        report = ExecutionStateReport(
            client="IB",
            account_id=TestStubs.account_id(),
            timestamp=UNIX_EPOCH,
        )

        cl_ord_id = ClientOrderId("O-123456")
        order_report = OrderStateReport(
            cl_ord_id=cl_ord_id,
            order_id=OrderId("1"),
            order_state=OrderState.REJECTED,
            filled_qty=Quantity(0),
            timestamp=UNIX_EPOCH,
        )

        # Act
        report.add_order_report(order_report)

        # Assert
        assert report.order_states()[cl_ord_id] == order_report

    def test_add_position_state_report(self):
        report = ExecutionStateReport(
            client="IB",
            account_id=TestStubs.account_id(),
            timestamp=UNIX_EPOCH,
        )

        position_report = PositionStateReport(
            instrument_id=AUDUSD_SIM,
            position_side=PositionSide.FLAT,
            qty=Quantity(0),
            timestamp=UNIX_EPOCH,
        )

        # Act
        report.add_position_report(position_report)

        # Assert
        assert report.position_states()[AUDUSD_SIM] == position_report
