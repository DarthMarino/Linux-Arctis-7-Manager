from arctis_manager.device_manager import (DeviceState, DeviceManager,
                                           DeviceStatus, InterfaceEndpoint)

BATTERY_MIN = 0x00
BATTERY_MAX = 0x04


class ArctisNova7Device(DeviceManager):
    def get_device_product_id(self) -> int:
        return 0x2202

    def get_device_name(self) -> str:
        return 'Arctis Nova 7'

    def manage_input_data(self, data: list[int], endpoint: InterfaceEndpoint) -> DeviceState:
        if endpoint == self.utility_guess_endpoint(7, 'in'):
            # Based on Arctis 7+ implementation
            # This might need adjustment based on actual Nova 7 protocol
            return DeviceState(data[1] / 100, data[2] / 100, 1, 1, DeviceStatus())

    def get_endpoint_addresses_to_listen(self) -> list[InterfaceEndpoint]:
        return [self.utility_guess_endpoint(7, 'in')]

    def get_request_device_status(self):
        return self.utility_guess_endpoint(7, 'out'), [0x06, 0xb0]