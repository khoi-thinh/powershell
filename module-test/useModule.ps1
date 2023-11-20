$inventory_file = "C:\ps_script\duckhoi.thinh\refine result\Japan Server Inventory.xlsx"
$input_csv_file = "C:\ps_script\duckhoi.thinh\refine result\Non-Edge PROD full.csv"
$output_excel_file = "C:\ps_script\duckhoi.thinh\refine result\Non-Edge PROD output.xlsx"

$input_params = @{
    InventoryExcelPath = $inventory_file
    InputCSVPath = $input_csv_file
    OutputExcelPath = $output_excel_file
}

Import-Module DecorateServer

Add-VMInformation @input_params
