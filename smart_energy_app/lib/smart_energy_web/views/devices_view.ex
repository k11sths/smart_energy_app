defmodule SmartEnergyWeb.DevicesView do
  @moduledoc false

  use SmartEnergyWeb, :view

  def render("get_available_devices.json", %{get_available_devices: get_available_devices}) do
    %{data: %{devices: Map.keys(get_available_devices)}}
  end
end
