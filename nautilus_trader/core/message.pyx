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

from typing import Any, Callable

from nautilus_trader.core.message cimport MessageCategory
from nautilus_trader.core.uuid cimport UUID


cdef class MessageCategoryParser:

    @staticmethod
    cdef str to_str(int value):
        if value == 1:
            return "COMMAND"
        elif value == 2:
            return "DOCUMENT"
        elif value == 3:
            return "EVENT"
        elif value == 4:
            return "REQUEST"
        elif value == 5:
            return "RESPONSE"
        else:
            raise ValueError(f"value was invalid, was {value}")

    @staticmethod
    cdef MessageCategory from_str(str value) except *:
        if value == "COMMAND":
            return MessageCategory.COMMAND
        elif value == "DOCUMENT":
            return MessageCategory.DOCUMENT
        elif value == "EVENT":
            return MessageCategory.EVENT
        elif value == "REQUEST":
            return MessageCategory.REQUEST
        elif value == "RESPONSE":
            return MessageCategory.RESPONSE
        else:
            raise ValueError(f"value was invalid, was {value}")

    @staticmethod
    def to_str_py(int value):
        return MessageCategoryParser.to_str(value)

    @staticmethod
    def from_str_py(str value):
        return MessageCategoryParser.from_str(value)


cdef class Message:
    """
    The abstract base class for all messages.

    This class should not be used directly, but through a concrete subclass.
    """

    def __init__(
        self,
        MessageCategory category,
        UUID message_id not None,
        int64_t ts_init,
    ):
        """
        Initialize a new instance of the ``Message`` class.

        Parameters
        ----------
        category : MessageCategory
            The message category.
        message_id : UUID
            The message ID.
        ts_init : int64
            The UNIX timestamp (nanoseconds) when the message object was initialized.

        """
        self.category = category
        self.id = message_id
        self.ts_init = ts_init

    def __eq__(self, Message other) -> bool:
        return self.category == other.category and self.id == other.id

    def __hash__(self) -> int:
        return hash((self.category, self.id))

    def __repr__(self) -> str:
        return f"{type(self).__name__}(id={self.id}, ts_init={self.ts_init})"


cdef class Command(Message):
    """
    The abstract base class for all commands.

    This class should not be used directly, but through a concrete subclass.
    """

    def __init__(
        self,
        UUID command_id not None,
        int64_t ts_init,
    ):
        """
        Initialize a new instance of the ``Command`` class.

        Parameters
        ----------
        command_id : UUID
            The command ID.
        ts_init : int64
            The UNIX timestamp (nanoseconds) when the command object was initialized.

        """
        super().__init__(MessageCategory.COMMAND, command_id, ts_init)


cdef class Document(Message):
    """
    The abstract base class for all documents.

    This class should not be used directly, but through a concrete subclass.
    """

    def __init__(
        self,
        UUID document_id not None,
        int64_t ts_init,
    ):
        """
        Initialize a new instance of the ``Document`` class.

        Parameters
        ----------
        document_id : UUID
            The document ID.
        ts_init : int64
            The UNIX timestamp (nanoseconds) when the document object was initialized.

        """
        super().__init__(MessageCategory.DOCUMENT, document_id, ts_init)


cdef class Event(Message):
    """
    The abstract base class for all events.

    This class should not be used directly, but through a concrete subclass.
    """

    def __init__(
        self,
        UUID event_id not None,
        int64_t ts_event,
        int64_t ts_init,
    ):
        """
        Initialize a new instance of the ``Event`` class.

        Parameters
        ----------
        event_id : UUID
            The event ID.
        ts_event : int64
            The UNIX timestamp (nanoseconds) when the event occurred.
        ts_init : int64
            The UNIX timestamp (nanoseconds) when the event object was initialized.

        """
        super().__init__(MessageCategory.EVENT, event_id, ts_init)

        self.ts_event = ts_event


cdef class Request(Message):
    """
    The abstract base class for all requests.

    This class should not be used directly, but through a concrete subclass.
    """

    def __init__(
        self,
        callback not None: Callable[[Any], None],
        UUID request_id not None,
        int64_t ts_init,
    ):
        """
        Initialize a new instance of the ``Request`` class.

        Parameters
        ----------
        callback : Callable[[Any], None]
            The callback to receive the response.
        request_id : UUID
            The request ID.
        ts_init : int64
            The UNIX timestamp (nanoseconds) when the request object was initialized.

        """
        super().__init__(MessageCategory.REQUEST, request_id, ts_init)

        self.callback = callback


cdef class Response(Message):
    """
    The abstract base class for all responses.

    This class should not be used directly, but through a concrete subclass.
    """

    def __init__(
        self,
        UUID correlation_id not None,
        UUID response_id not None,
        int64_t ts_init,
    ):
        """
        Initialize a new instance of the ``Response`` class.

        Parameters
        ----------
        correlation_id : UUID
            The correlation ID.
        response_id : UUID
            The response ID.
        ts_init : int64
            The UNIX timestamp (nanoseconds) when the response object was initialized.

        """
        super().__init__(MessageCategory.RESPONSE, response_id, ts_init)

        self.correlation_id = correlation_id

    def __repr__(self) -> str:
        return (f"{type(self).__name__}("
                f"correlation_id={self.correlation_id}, "
                f"id={self.id}, "
                f"ts_init={self.ts_init})")