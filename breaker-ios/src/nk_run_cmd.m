#import "nk_run_cmd.h"

int nk_run_cmd(const char *cmd) {
    pid_t pid;
    int status;

    if (cmd == NULL) {
         //如果cmdstring为空，返回非零值，一般为1
        return (1);
    }

    if ( (pid = fork()) < 0 ) {
        //fork失败，返回-1
        status = -1; 

    } else if (pid == 0) {
        execl("/bin/sh", "sh", "-c", cmd, (char *)0);
        // exec执行失败返回127，注意exec只在失败时才返回现在的进程，成功的话现在的进程就不存在啦~~
        _exit(127); 
    } else {
        //父进程
        while(waitpid(pid, &status, 0) < 0) {
            if(errno != EINTR) {
                //如果waitpid被信号中断，则返回-1
                status = -1; 
                break;
            }
        }
    }

    //如果waitpid成功，则返回子进程的返回状态
    return status; 
}
