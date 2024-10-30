# script_to_modify_env.py
def remove_values_in_env(input_file, output_file):
    with open(input_file, 'r') as file:
        lines = file.readlines()
    
    new_lines = [line.split('=')[0] + '=\n' for line in lines if '=' in line]
    
    with open(output_file, 'w') as file:
        file.writelines(new_lines)

if __name__ == "__main__":
    remove_values_in_env(".env", "dev.env")
    print("clean dev.env DONE")
