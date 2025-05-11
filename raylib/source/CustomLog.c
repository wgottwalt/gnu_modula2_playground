#include <stdint.h>
#include <stdio.h>
#include <time.h>
#include <raylib.h>

void CustomLog(int32_t msg_type, const char *text, va_list args)
{
	const time_t now = time(NULL);
	const struct tm *tm = localtime(&now);
	char time_str[64] = {0};

	strftime(time_str, sizeof (time_str), "%Y-%m-%d %H:%M:%S", tm);
	printf("[%s]", time_str);

	switch (msg_type) {
	case LOG_INFO:
		printf("[INFO] : ");
		break;
	case LOG_ERROR:
		printf("[ERROR]: ");
		break;
	case LOG_WARNING:
		printf("[WARN] : ");
		break;
	case LOG_DEBUG:
		printf("[DEBUG]: ");
		break;
	default:
		printf("[UNDEF]: ");
		break;
	}

	vprintf(text, args);
	printf("\n");
}
