#include <stdio.h>
#include <pciaccess.h>

int32_t main(void)
{
	struct pci_agp_info agp_info;
	struct pci_mem_region mem_region;

	printf("agp_info (type, instance):   %ld %ld \n", sizeof (struct pci_agp_info),
		sizeof (agp_info));
	printf("mem_region (type, instance): %ld %ld \n", sizeof (struct pci_mem_region),
		sizeof (mem_region));

	return 0;
}
