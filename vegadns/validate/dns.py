import re


class ValidateDNS(object):

    @staticmethod
    def record_hostname(hostname):
        # All record hostnames must be at least a second level
        if hostname.count('.') < 1:
            return False

        longregex = (
            '^(\*\.)?'
            '([a-z0-9_]\.|[a-z0-9_][a-z0-9_-]*[a-z0-9_]\.)*'
            '([a-z0-9_]|[a-z0-9_][a-z0-9_-]*[a-z0-9_])\.?$'
        )
        p = re.compile(longregex, re.IGNORECASE)

        if p.match(hostname):
            return True
        return False
