import matplotlib.pyplot as plt
import pandas as pd
import os

def generate_time_exec_graph(df_, col, save_path, title, subtitles):
    df = df_.copy(deep=True)
    df.plot(kind='line', title=title, legend=None)

    plt.xlabel(col)
    plt.ylabel('Time execution')
    plt.savefig(save_path, dpi=200)
    plt.close()

def generate_speedups_graph(dfs, save_path, title, subtitles):
    fig, ax = plt.subplots()
    for d in range(len(dfs)):
        dfs[d].plot(kind='line', ax=ax)

    plt.legend(subtitles)
    plt.xlabel('Threads/Process')
    plt.ylabel('Speedup')
    plt.title(title)
    plt.savefig(save_path, dpi=200)
    plt.close()


def generate_speedup_table(df, seq_value,  col_name):
    speed_up = pd.DataFrame(columns=[col_name, 'time', 'S'])

    speed_up['time'] = df['time']
    speed_up['S'] = df['time'] / seq_value
    speed_up['S'] = speed_up['S']
    speed_up[col_name] = df[col_name]
    speed_up.set_index(col_name, inplace=True)
    
    return speed_up

def data_final(dfs, col, title):
    path_table = f"./results/{title}_table.csv"
    path_img = "./results/" + title + ".png"

    data_speed = pd.DataFrame({ 'Password': ["senhate"],
                            'OpenMP': [dfs[0][col].max()],
                            'MPI': [dfs[1][col].max()],
                            'OpenMPI':[ dfs[2][col].max()]
                            }
                            )
    if os.path.exists(path_table):
        dt = pd.read_csv(path_table, sep=";")
        print(dt.head())
        data_speed = pd.concat([dt, data_speed])
        print(data_speed.head())

    data_speed.to_csv(path_table, sep=";", index=False)
    data_speed.set_index('Password', inplace=True)
    data_speed.plot(kind='bar', rot=0, title=title, width=0.35)
    plt.ylabel(title.lower())
    plt.savefig(path_img, dpi=200)
    plt.close()


omp = pd.read_csv("./omp", sep=";")

mpi = pd.read_csv("./mpi", sep=";")

openmpi = pd.read_csv("./openmpi", sep=";")

seq = pd.read_csv("./seq", sep=";", header=None)
seq.dropna(axis=1, inplace=True)

seq_value = seq.values[0][0]

subtitles = ['OpenMP', 'MPI']
dfs = []
dfs.append(generate_speedup_table(omp, seq_value, 'num_threads'))
dfs.append(generate_speedup_table(mpi, seq_value, 'num_process'))

generate_time_exec_graph(dfs[0], 'num_threads', "./omp_time.png", 'Time execution by threads', 'threads')
generate_time_exec_graph(dfs[1], 'num_process', "./mpi_time.png", 'Time execution by process', 'process')

generate_speedups_graph(dfs, "./speed_up.png", 'Speedups in OpenMP & MPI', subtitles)
dfs.append(generate_speedup_table(openmpi, seq_value, 'num_process'))


# data_final(dfs, 'S', 'Speedup')
# data_final(dfs, 'time', 'Time')