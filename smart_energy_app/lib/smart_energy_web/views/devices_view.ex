defmodule SmartEnergyWeb.DevicesView do
  @moduledoc false

  use SmartEnergyWeb, :view

  def render("get_available_devices.json", %{get_available_devices: get_available_devices}) do
    %{data: %{devices: Map.keys(get_available_devices)}}
  end

  def render("pair_device_success.json", %{device_id: device_id}) do
    %{data: %{device_paired: device_id}}
  end

  def render("get_paired_devices.json", %{paired_devices: paired_devices}) do
    %{data: %{paired_devices: Map.keys(paired_devices)}}
  end

  def render("get_paired_device_data.json", %{paired_device: paired_device}) do
    %{data: %{paired_device: paired_device}}
  end

  def render("change_device_status.json", %{device_id: device_id, status: status}) do
    %{data: %{new_status: status, device_id: device_id}}
  end
end
